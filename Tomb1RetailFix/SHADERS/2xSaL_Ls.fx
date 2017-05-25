/*

   Copyright (C) 2007 guest(r) - guest.r@gmail.com

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

/*

   The 2xSaL_Ls shader processes a gfx. surface and redraws it 2x finer.
   
   A linear post-resize can fit the image nicely to any resolution.

   Note: set scaler to normal2x.

*/



#include "shader.code"

float scaling   : SCALING = 0.1;


string preprocessTechique : PREPROCESSTECHNIQUE = "SaL";
string combineTechique : COMBINETECHNIQUE =  "Ls";



// **VS**

VERTEX_STUFF0 S_VERTEX (float3 p : POSITION, float2 tc : TEXCOORD0)
{
  VERTEX_STUFF0 OUT = (VERTEX_STUFF0)0;
  
  float dx = ps.x*0.5;
  float dy = ps.y*0.5;

  OUT.coord = mul(float4(p,1),WorldViewProjection);
  OUT.CT = tc;
  OUT.t1.xy = tc + float2(-dx, 0);
  OUT.t2.xy = tc + float2( dx, 0);
  OUT.t3.xy = tc + float2( 0,-dy);
  OUT.t4.xy = tc + float2( 0, dy);
  OUT.t1.zw = tc + float2(-dx,-dy);
  OUT.t2.zw = tc + float2(-dx, dy);
  OUT.t3.zw = tc + float2( dx,-dy);
  OUT.t4.zw = tc + float2( dx, dy);

  return OUT;
}

// **PS**

float4 S_FRAGMENT ( in VERTEX_STUFF0 VAR ) : COLOR
{
   half3 c00 = tex2D(s_p, VAR.t1.zw).xyz; 
   half3 c10 = tex2D(s_p, VAR.t3.xy).xyz; 
   half3 c20 = tex2D(s_p, VAR.t3.zw).xyz; 
   half3 c01 = tex2D(s_p, VAR.t1.xy).xyz; 
   half3 c11 = tex2D(s_p, VAR.CT).xyz; 
   half3 c21 = tex2D(s_p, VAR.t2.xy).xyz; 
   half3 c02 = tex2D(s_p, VAR.t2.zw).xyz; 
   half3 c12 = tex2D(s_p, VAR.t4.xy).xyz; 
   half3 c22 = tex2D(s_p, VAR.t4.zw).xyz;

   float d1= dot(abs(c00-c22),dt)+0.01;
   float d2= dot(abs(c20-c02),dt)+0.01;
   float hl= dot(abs(c01-c21),dt)+0.01;
   float vl= dot(abs(c10-c12),dt)+0.01;

   hl =sqrt(1.0/hl); vl= sqrt(1.0/vl);
   d1 = 1.0/(d1*d1); d2 = 1.0/(d2*d2);

   float ww = hl+vl+d1+d2;	
 
   return float4 (((hl*(c10+c12)+vl*(c01+c21)+d2*(c20+c02)+d1*(c00+c22))/(2.0*ww)),1);

}

VERTEX_STUFF0 S_VERTEX0 (float3 p : POSITION, float2 tc : TEXCOORD0)
{
  VERTEX_STUFF0 OUT = (VERTEX_STUFF0)0;
  
  OUT.coord = mul(float4(p,1),WorldViewProjection);
  OUT.CT = tc;

  return OUT;
}

// **PS**

float4 S_FRAGMENT0 ( in VERTEX_STUFF0 VAR ) : COLOR
{

   half3 c11 = tex2D(w_l, VAR.CT).xyz; 

   return float4 (c11,1);

}
technique SaL
{
   pass P0
   {
     VertexShader = compile vs_2_0 S_VERTEX();
     PixelShader  = compile ps_2_0 S_FRAGMENT();
   }  
}


technique Ls
{
   pass P0
   {
     VertexShader = compile vs_2_0 S_VERTEX0();
     PixelShader  = compile ps_2_0 S_FRAGMENT0();
     Sampler[0] = (w_l);
   }  
}
