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

   The 2xSaL shader processes a gfx. surface and redraws it 2x finer.
   
   A linear post-resize can fit the image to any resolution.

   Note: set scaler to normal2x.

*/



#include "shader.code"

float scaling   : SCALING = 1.01;


string preprocessTechique : PREPROCESSTECHNIQUE = "SaL";
string combineTechique : COMBINETECHNIQUE =  "Ls";



// **VS**

VERTEX_STUFF1 GS2X_VERTEX (float3 p : POSITION, float2 tc : TEXCOORD0)
{
  VERTEX_STUFF1 OUT = (VERTEX_STUFF1)0;
  
  float dx = ps.x*0.25;
  float dy = ps.y*0.25;

  OUT.coord = mul(float4(p,1),WorldViewProjection);
  OUT.CT = tc;
  OUT.UL = tc + float2(-dx,-dy);
  OUT.UR = tc + float2( dx,-dy);
  OUT.DL = tc + float2(-dx, dy);
  OUT.DR = tc + float2( dx, dy);
  return OUT;
}


float4 GS_FRAGMENT ( in VERTEX_STUFF1 VAR ) : COLOR

{
  half3 c00 = tex2D(s_p, VAR.UL).xyz;
  half3 c20 = tex2D(s_p, VAR.UR).xyz;
  half3 c02 = tex2D(s_p, VAR.DL).xyz;
  half3 c22 = tex2D(s_p, VAR.DR).xyz;
	
  half m1=dot(abs(c00-c22),dt)+0.001;
  half m2=dot(abs(c02-c20),dt)+0.001;
  
  return float4((m1*(c02+c20)+m2*(c22+c00))/(2.0*(m1+m2)),0);
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
     VertexShader = compile vs_2_0 GS2X_VERTEX();
     PixelShader  = compile ps_2_0 GS_FRAGMENT();
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
