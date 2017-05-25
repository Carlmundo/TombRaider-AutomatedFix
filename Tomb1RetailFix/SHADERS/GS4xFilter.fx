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

   The gs4xfilter shader processes a gfx. surface and tries to draw it 4x finer.
  
   It can be used well to:
   
   - scale an "image" to a 4x size (like 320x200->1280x800)

   and so-so to:

   - scale an "image" to a 2x size, (i.e. 640x480 -> 1280x960)

   Some games use different resolutions, so this aditional feature may proove helpful.


   This shader tries to produce a richer final color environment by interpolation
 
   while maintaining good contrast. Due the nature of the implementation is it best used

   with "games" that use at least 256 colors.

   The "color weight" formulas can be influenced by certain parameters so the final image

   can be fuzzy or sharper.

   To fit into the PS 2.0 limitations some compromises must been made which results in a somewhat crude

   filtering "post effect".

*/


#include "shader.code"

float scaling   : SCALING = 2.0;


string name : NAME = "GS4xFilter";
string combinetechnique : COMBINETECHNIQUE =  "GS4xFilter";


// **VS**

VERTEX_STUFF2 GS_VERTEX (float3 p : POSITION, float2 tc : TEXCOORD0)
{
  VERTEX_STUFF2 OUT = (VERTEX_STUFF2)0;
  
  float dx = ps.x*0.50;
  float dy = ps.y*0.50;
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

  half sd1 = dot(abs(i1-i3),dt);
  half sd2 = dot(abs(i2-i4),dt);

  half4 w;
  w.yw = min(sd1,max(ko1,ko3));
  w.xz = min(sd2,max(ko2,ko4));

  if (ko3<ko1) w.x = 0.0;
  if (ko4<ko2) w.y = 0.0;
  if (ko1<ko3) w.z = 0.0;
  if (ko2<ko4) w.w = 0.0;  
  
  c = (w.x*o1+w.y*o2+w.z*o3+w.w*o4+0.001*c)/(dot(w,d4)+0.001);
  
  w.z = -0.25/(0.4*dot(c,dt)+0.25);

  w.x = max(w.z*sd1+0.25,0.0); 
  w.y = max(w.z*sd2+0.25,0.0);

  return float4((w.x*(i1+i3) + w.y*(i2+i4) + (1.0-2.0*(w.x+w.y))*c),0);
}


technique GS4xFilter
{
    pass P0
    {
	VertexShader = compile vs_2_0 GS_VERTEX();
	PixelShader  = compile ps_2_0 GS_FRAGMENT();
    }  
}
