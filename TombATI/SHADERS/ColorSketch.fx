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

  The shader tries to make a "colored sketch" of the screen that is currently being
  drawn.

*/

#include "shader.code"


string name : NAME = "colorsketch";
string combineTechique : COMBINETECHNIQUE =  "colorsketch";


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
   half3 pap = half3(0.83, 0.79, 0.63);
   half3 c00 = tex2D(s_l, VAR.t1.zw).xyz; 
   half3 c10 = tex2D(s_l, VAR.t3.xy).xyz; 
   half3 c20 = tex2D(s_l, VAR.t3.zw).xyz; 
   half3 c01 = tex2D(s_l, VAR.t1.xy).xyz; 
   half3 c11 = tex2D(s_l, VAR.CT).xyz; 
   half3 c21 = tex2D(s_l, VAR.t2.xy).xyz; 
   half3 c02 = tex2D(s_l, VAR.t2.zw).xyz; 
   half3 c12 = tex2D(s_l, VAR.t4.xy).xyz; 
   half3 c22 = tex2D(s_l, VAR.t4.zw).xyz; 

   half d1=dot(abs(c00-c22),dt);
   half d2=dot(abs(c20-c02),dt);
   half hl=dot(abs(c01-c21),dt);
   half vl=dot(abs(c10-c12),dt);

   half d = 0.55*(d1+d2+hl+vl)/(dot(c11+c10+c02+c22,dt)+0.3); 
   d+=  0.5*pow(d,0.5);
   c11*= (1.0-0.6*d); d+=0.1;
   d = pow(d,1.25-1.25*min(2.0*d,1.0));
   return half4 (d*c11 + (1.1-d)*pap,1);
}


technique colorsketch
{
   pass P0
   {
     VertexShader = compile vs_2_0 S_VERTEX();
     PixelShader  = compile ps_2_0 S_FRAGMENT();
   }  
}
