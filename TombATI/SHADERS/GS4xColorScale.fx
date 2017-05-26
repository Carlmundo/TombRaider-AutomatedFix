/*

   Copyright (C) 2005 guest(r) - guest.r@gmail.com

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

   The gs4xColorScale shader processes a gfx. surface and tries to draw it 4x finer.
  
   It can be used well to:
   
   - scale an "image" to a 4x size (like 320x200->1280x800)

   and so-so to:

   - scale an "image" to a 2x size, (i.e. 640x480 -> 1280x960)

   Some games use different resolutions, so this aditional feature may proove helpful.


   An aditional feature of this shader is the customisable color effect (multiplicative brightness,

   seperate color channel adjustments, brightness preserving saturation, centered contrast).

   To adjust the color effect the shader variables (c_ch, a, b...) must be altered.
			
*/

#include "shader.code"

float scaling   : SCALING = 2.0;


// color params

half3  c_ch = half3 (1.0, 1.0, 1.0); // color channel (r,g,b) intensity
half      a =  2.000;                // saturation 
half      b =  1.000;                // brightness
half      c1=  2.150;                // contrast 1 funct param.
half      c2=  1.400;                // contrast funct. 2 param, good values between (-1.0,2.0)

// contrast function 1

float contrast1(float x)
{ return clamp(0.866 + c1*(x-0.866),0.01, 1.731); }


// contrast function 2

float contrast2(float x)
{ 
  float y = x*1.1547-1.0;
  y = (sin(y*1.5707963272)+1.0)*0.86602540;
  return (1-c2)*x + c2*y;
}


string name : NAME = "GS4xColorScale";

string preprocessTechique : PREPROCESSTECHNIQUE = "COLOR";
string combineTechique : COMBINETECHNIQUE =  "GS4xSCALE";


// gs4x vertex

VERTEX_STUFF2 GS4X_VERTEX (float3 p : POSITION, float2 tc : TEXCOORD0)
{
  VERTEX_STUFF2 OUT = (VERTEX_STUFF2)0;
  
  float dx = ps.x*0.5;
  float dy = ps.y*0.5;
  float sx = ps.x*0.25;
  float sy = ps.y*0.25;

  OUT.coord = mul(float4(p,1),WorldViewProjection);
  OUT.CT = tc;
  OUT.UL = tc + float2(-dx,-dy);
  OUT.UR = tc + float2( dx,-dy);
  OUT.DL = tc + float2(-dx, dy);
  OUT.DR = tc + float2( dx, dy);
  
  OUT.iUL = tc + float2(-sx,-sy);
  OUT.iUR = tc + float2( sx,-sy);
  OUT.iDD = float4(tc,tc) + float4(-sx, sy, sx, sy);
  
return OUT;

}

// color vertex

VERTEX_STUFF_W COLOR_VERTEX (float3 p : POSITION, float2 tc : TEXCOORD0)
{
  VERTEX_STUFF_W OUT = (VERTEX_STUFF_W)0;
  
  OUT.coord = mul(float4(p,1),WorldViewProjection);
  OUT.CT = tc;
  return OUT;
}


// GS PS
float4 GS4X_FRAGMENT ( in VERTEX_STUFF2 VAR ) : COLOR

{
  half3 c  = tex2D(s_w, VAR.CT).xyz;
  half3 o1 = tex2D(s_w, VAR.UL).xyz;
  half3 o2 = tex2D(s_w, VAR.UR).xyz;
  half3 o3 = tex2D(s_w, VAR.DR).xyz;
  half3 o4 = tex2D(s_w, VAR.DL).xyz;
  half3 i1 = tex2D(s_w, VAR.iUL).xyz;
  half3 i2 = tex2D(s_w, VAR.iUR).xyz;
  half3 i3 = tex2D(s_w, VAR.iDD.zw).xyz;
  half3 i4 = tex2D(s_w, VAR.iDD.xy).xyz;

  half ko1=dot(abs(o1-c),dt);
  half ko2=dot(abs(o2-c),dt);
  half ko3=dot(abs(o3-c),dt);
  half ko4=dot(abs(o4-c),dt);

  half k1=min(dot(abs(i1-i3),dt),dot(abs(o1-o3),dt));
  half k2=min(dot(abs(i2-i4),dt),dot(abs(o2-o4),dt));
  
  half4 w = half4(k2,k1,k2,k1);

  if (ko3<ko1) w.x = 0.0;
  if (ko4<ko2) w.y = 0.0;
  if (ko1<ko3) w.z = 0.0;
  if (ko2<ko4) w.w = 0.0;  

  return float4((w.x*o1+w.y*o2+w.z*o3+w.w*o4+0.0001*c)/(dot(w,d4)+0.0001),0);
}

// cOLOR PS

float4 COLOR_FRAGMENT ( in VERTEX_STUFF_W VAR ) : COLOR

{
  half3 color = tex2D(s_p, VAR.CT).xyz;
  
  half x  = sqrt(dot(color,color));   
  color.r = pow(color.r+0.025,a);
  color.g = pow(color.g+0.025,a);
  color.b = pow(color.b+0.025,a);
  return float4(contrast2(x)*normalize(color*c_ch)*b,1);
}


technique COLOR
{
   pass P0
   {
     VertexShader = compile vs_2_0 COLOR_VERTEX();
     PixelShader  = compile ps_2_0 COLOR_FRAGMENT();
     Sampler[0] = (s_p);
   }  
}


technique GS4xSCALE
{
   pass P0
   {
     VertexShader = compile vs_2_0 GS4X_VERTEX();
     PixelShader  = compile ps_2_0 GS4X_FRAGMENT();
     Sampler[0] = (s_w);
   }  
}
