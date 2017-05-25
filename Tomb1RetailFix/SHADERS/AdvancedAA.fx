/*

   Copyright (C) 2006 guest(r) - guest.r@gmail.com

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

   The AdvancedAA shader is well used to:
   
   - AA 2xscaled gfx. to its 4x absolute size,   

   - AA hi-res "screens" (640x480) to their 2x size or,

   - AA gfx. back to it's original size (looks nice above 640x480, set scaling to 1.0) 

*/

#include "shader.code"

float scaling   : SCALING = 2.0;

string name : NAME = "AdvancedAA";
string combineTechique : COMBINETECHNIQUE =  "AdvancedAA";


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

   float d1=dot(abs(c00-c22),dt)+0.0001;
   float d2=dot(abs(c20-c02),dt)+0.0001;
   float hl=dot(abs(c01-c21),dt)+0.0001;
   float vl=dot(abs(c10-c12),dt)+0.0001;
	
   float k1=0.5*(hl+vl);
   float k2=0.5*(d1+d2);
	
   float3 t1=(hl*(c10+c12)+vl*(c01+c21)+k1*c11)/(2.5*(hl+vl));
   float3 t2=(d1*(c20+c02)+d2*(c00+c22)+k2*c11)/(2.5*(d1+d2));

   k1=dot(abs(t1-c11),dt)+0.0001;
   k2=dot(abs(t2-c11),dt)+0.0001;

   return float4((k1*t2+k2*t1)/(k1+k2),1);
}


technique AdvancedAA
{
   pass P0
   {
     VertexShader = compile vs_2_0 S_VERTEX();
     PixelShader  = compile ps_2_0 S_FRAGMENT();
   }  
}
