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

   The gs4xScale shader processes a gfx. surface and tries to draw it 4x finer.
  
   It can be used well to:
   
   - scale an "image" into a 4x size (like 320x200->1280x800)

   and so-so to:

   - scale an "image" to a 2x size, (i.e. 640x480 -> 1280x960)

   Some games use different resolutions, so this aditional feature may proove as helpful.

   A speciality of this shader is well seen and dominating transposition effect.

   The edges might turn out jagged, but the shader copes out with consistency. 
	
*/

#include "shader.code"

float scaling   : SCALING = 2.0;


string name : NAME = "GS4xScale";
string combineTechique : COMBINETECHNIQUE =  "GS4xScale";


// **VS**

VERTEX_STUFF2 GS_VERTEX (float3 p : POSITION, float2 tc : TEXCOORD0)
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

// **PS**

float4 GS_FRAGMENT ( in VERTEX_STUFF2 VAR ) : COLOR

{
  half3 c  = tex2D(s_p, VAR.CT).xyz;
  half3 o1 = tex2D(s_p, VAR.UL).xyz;
  half3 o2 = tex2D(s_p, VAR.UR).xyz;
  half3 o3 = tex2D(s_p, VAR.DR).xyz;
  half3 o4 = tex2D(s_p, VAR.DL).xyz;
  half3 i1 = tex2D(s_p, VAR.iUL).xyz;
  half3 i2 = tex2D(s_p, VAR.iUR).xyz;
  half3 i3 = tex2D(s_p, VAR.iDD.zw).xyz;
  half3 i4 = tex2D(s_p, VAR.iDD.xy).xyz;

  half ko1=dot(abs(o1-c),dt);
  half ko2=dot(abs(o2-c),dt);
  half ko3=dot(abs(o3-c),dt);
  half ko4=dot(abs(o4-c),dt);

  half k1=dot(abs(i1-i3),dt)*dot(abs(o1-o3),dt);
  half k2=dot(abs(i2-i4),dt)*dot(abs(o2-o4),dt);
  
  half4 w = half4(k2,k1,k2,k1);

  if (ko3<ko1) w.x = 0.0;
  if (ko4<ko2) w.y = 0.0;
  if (ko1<ko3) w.z = 0.0;
  if (ko2<ko4) w.w = 0.0;  

  return float4((w.x*o1+w.y*o2+w.z*o3+w.w*o4+0.0001*c)/(dot(w,d4)+0.0001),0);
}


technique GS4xScale
{
    pass P0
    {
	VertexShader = compile vs_2_0 GS_VERTEX();
	PixelShader  = compile ps_2_0 GS_FRAGMENT();
    }  
}
