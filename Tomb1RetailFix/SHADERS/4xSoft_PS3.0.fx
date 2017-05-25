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

   The 4xSoft shader processes a gfx. surface and redraws it 4x finer.

   Note: set scaler to normal2x.

*/



#include "shader.code"

float scaling   : SCALING = 2.0;


string name : NAME = "Soft";
string combinetechnique : COMBINETECHNIQUE =  "soft";


// **VS**

VERTEX_STUFF4 GS_VERTEX (float3 p : POSITION, float2 tc : TEXCOORD0)
{
  VERTEX_STUFF4 OUT = (VERTEX_STUFF4)0;
  
  float dx = ps.x;
  float dy = ps.y;
  float sx = ps.x*0.5;
  float sy = ps.y*0.5;

  OUT.coord = mul(float4(p,1),WorldViewProjection);
  OUT.CT = tc;

  OUT.t1 = float4(tc,tc) + float4(-dx,-dy, dx,-dy); // outer diag. texels
  OUT.t2 = float4(tc,tc) + float4( dx, dy,-dx, dy);
  OUT.t3 = float4(tc,tc) + float4(-sx,-sy, sx,-sy); // inner diag. texels
  OUT.t4 = float4(tc,tc) + float4( sx, sy,-sx, sy);
  OUT.t5 = float4(tc,tc) + float4(-dx,  0, dx,  0); // inner hor/vert texels
  OUT.t6 = float4(tc,tc) + float4(  0,-dy,  0, dy);

return OUT;
}


// **PS**

float4 GS_FRAGMENT ( in VERTEX_STUFF4 VAR ) : COLOR

{
  half3 c11 = tex2D(s_p, VAR.CT   ).xyz;
  half3 c00 = tex2D(s_p, VAR.t1.xy).xyz;
  half3 c20 = tex2D(s_p, VAR.t1.zw).xyz;
  half3 c22 = tex2D(s_p, VAR.t2.xy).xyz;
  half3 c02 = tex2D(s_p, VAR.t2.zw).xyz;
  half3 s00 = tex2D(s_p, VAR.t3.xy).xyz;
  half3 s20 = tex2D(s_p, VAR.t3.zw).xyz;
  half3 s22 = tex2D(s_p, VAR.t4.xy).xyz;
  half3 s02 = tex2D(s_p, VAR.t4.zw).xyz;
  half3 c01 = tex2D(s_p, VAR.t5.xy).xyz;
  half3 c21 = tex2D(s_p, VAR.t5.zw).xyz;
  half3 c10 = tex2D(s_p, VAR.t6.xy).xyz;
  half3 c12 = tex2D(s_p, VAR.t6.zw).xyz;

  float d1=dot(abs(c00-c22),dt)+0.001;
  float d2=dot(abs(c20-c02),dt)+0.001;
  float hl=dot(abs(c01-c21),dt)+0.001;
  float vl=dot(abs(c10-c12),dt)+0.001;
  float m1=dot(abs(s00-s22),dt)+0.001;
  float m2=dot(abs(s02-s20),dt)+0.001;

  float md = d1+d2;   float mc = hl+vl;
  hl*=  md;vl*= md;   d1*=  mc;d2*= mc;
	
  float ww = d1+d2+vl+hl;
        
  c11=(hl*(c10+c12)+vl*(c01+c21)+d1*(c20+c02)+d2*(c00+c22)+ww*c11)/(3.0*ww);

  return float4(0.5*(c11+0.5*(m2*(s00+s22)+m1*(s02+s20))/(m1+m2)),0);
}


technique soft
{
    pass P0
    {
	VertexShader = compile vs_3_0 GS_VERTEX();
	PixelShader  = compile ps_3_0 GS_FRAGMENT();
    }  
}
