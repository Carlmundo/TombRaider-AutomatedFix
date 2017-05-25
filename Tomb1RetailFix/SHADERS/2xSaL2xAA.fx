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

   The 2xSaL2xAA shader is well used to scale a buffer(part) to a total size of 4x (i.e. 320x200->1280x800).

   Note: set scaler to normal2x.

*/


#include "shader.code"

float scaling   : SCALING = 2.0;



string name : NAME = "GSone";

string preprocessTechique : PREPROCESSTECHNIQUE = "SaL";
string combineTechique : COMBINETECHNIQUE =  "AA";



VERTEX_STUFF1 GS2X_VERTEX (float3 p : POSITION, float2 tc : TEXCOORD0)
{
  VERTEX_STUFF1 OUT = (VERTEX_STUFF1)0;
  
  float dx = ps.x*0.5;
  float dy = ps.y*0.5;

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



VERTEX_STUFF0 S_VERTEX (float3 p : POSITION, float2 tc : TEXCOORD0)
{
  VERTEX_STUFF0 OUT = (VERTEX_STUFF0)0;
  
  float dx = ps.x*0.5;
  float dy = ps.y*0.5;

  OUT.coord = mul(float4(p,1),WorldViewProjection);
  OUT.CT = tc;
  OUT.t1.xy = tc + float2(-dx,  0);
  OUT.t2.xy = tc + float2( dx,  0);
  OUT.t3.xy = tc + float2(  0,-dy);
  OUT.t4.xy = tc + float2(  0, dy);
  OUT.t1.zw = tc + float2(-dx,-dy);
  OUT.t2.zw = tc + float2(-dx, dy);
  OUT.t3.zw = tc + float2( dx,-dy);
  OUT.t4.zw = tc + float2( dx, dy);

  return OUT;
}

// **PS**

float4 S_FRAGMENT ( in VERTEX_STUFF0 VAR ) : COLOR
{
   half3 c00 = tex2D(s_w, VAR.t1.zw).xyz; 
   half3 c10 = tex2D(s_w, VAR.t3.xy).xyz; 
   half3 c20 = tex2D(s_w, VAR.t3.zw).xyz; 
   half3 c01 = tex2D(s_w, VAR.t1.xy).xyz; 
   half3 c11 = tex2D(s_w, VAR.CT).xyz; 
   half3 c21 = tex2D(s_w, VAR.t2.xy).xyz; 
   half3 c02 = tex2D(s_w, VAR.t2.zw).xyz; 
   half3 c12 = tex2D(s_w, VAR.t4.xy).xyz; 
   half3 c22 = tex2D(s_w, VAR.t4.zw).xyz;

   float d1=dot(abs(c00-c22),dt)+0.001;
   float d2=dot(abs(c20-c02),dt)+0.001;
   float hl=dot(abs(c01-c21),dt)+0.001;
   float vl=dot(abs(c10-c12),dt)+0.001;

   float md = d1+d2;  float mc = hl+vl;
   hl*=  md;vl*= md;  d1*=  mc;d2*= mc;
	
   float ww = d1+d2+hl+vl;

   return float4 ((hl*(c10+c12)+vl*(c01+c21)+d1*(c20+c02)+d2*(c00+c22)+ww*c11)/(3.0*ww),1);
}



technique SaL
{
   pass P0
   {
     VertexShader = compile vs_2_0 GS2X_VERTEX();
     PixelShader  = compile ps_2_0 GS_FRAGMENT();
     Sampler[0] = (s_p);
   }  
}


technique AA
{
   pass P0
   {
     VertexShader = compile vs_2_0 S_VERTEX();
     PixelShader  = compile ps_2_0 S_FRAGMENT();
     Sampler[0] = (s_w);
   }  
}
