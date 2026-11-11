// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PP_FlashBang"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_GhostTex("GhostTex", 2D) = "white" {}
		_GhostDesaturate("GhostDesaturate", Range( 0 , 1)) = 0.6
		_GhostTint("GhostTint", Color) = (1,1,1,1)
		_GhostAlpha("GhostAlpha", Range( 0 , 1)) = 0
		_FlashColor("FlashColor", Color) = (1,0.97,0.92,1)
		_Flash("Flash", Range( 0 , 1)) = 0

	}

	SubShader
	{
		LOD 0

		
		
		ZTest Always
		Cull Off
		ZWrite Off

		
		Pass
		{ 
			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			

			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform sampler2D _GhostTex;
			uniform float _GhostDesaturate;
			uniform float4 _GhostTint;
			uniform float _GhostAlpha;
			uniform float4 _FlashColor;
			uniform float _Flash;


			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float2 texCoord2 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float4 pantalla4 = tex2D( _MainTex, texCoord2 );
				float2 texCoord6 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float3 desaturateInitialColor9 = tex2D( _GhostTex, texCoord6 ).rgb;
				float desaturateDot9 = dot( desaturateInitialColor9, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar9 = lerp( desaturateInitialColor9, desaturateDot9.xxx, _GhostDesaturate );
				float4 lerpResult14 = lerp( pantalla4 , ( float4( desaturateVar9 , 0.0 ) * _GhostTint ) , _GhostAlpha);
				float4 conFantasma15 = lerpResult14;
				float4 lerpResult19 = lerp( conFantasma15 , _FlashColor , _Flash);
				

				finalColor = lerpResult19;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
289;72;903;544.5;204.0695;548.5108;2.007767;False;False
Node;AmplifyShaderEditor.CommentaryNode;21;-2230.637,-9.226198;Inherit;False;1854;515;Imagen fantasma;11;5;6;7;8;9;10;11;12;13;14;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;20;-39.21643,-391.0755;Inherit;False;974;326;Pantalla;4;1;2;3;4;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;1;10.78355,-341.0754;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;10.78355,-221.0756;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;5;-2180.636,120.7738;Inherit;True;Property;_GhostTex;GhostTex;0;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-2180.636,320.7738;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;8;-1830.637,370.7738;Inherit;False;Property;_GhostDesaturate;GhostDesaturate;1;0;Create;True;0;0;0;False;0;False;0.6;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;360.7836,-341.0754;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-1830.637,120.7738;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;10;-1480.637,290.7738;Inherit;False;Property;_GhostTint;GhostTint;2;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;4;710.7835,-341.0754;Inherit;False;pantalla;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DesaturateOpNode;9;-1480.637,140.7738;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1200.637,390.7739;Inherit;False;Property;_GhostAlpha;GhostAlpha;3;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-1200.637,180.7738;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;12;-1200.637,40.77377;Inherit;False;4;pantalla;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;14;-900.6369,140.7738;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-600.6368,140.7738;Inherit;False;conFantasma;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;22;400,-50;Inherit;False;582;495;Flash;4;16;17;18;19;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;450,0;Inherit;False;15;conFantasma;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;18;450,330;Inherit;False;Property;_Flash;Flash;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;450,130;Inherit;False;Property;_FlashColor;FlashColor;4;0;Create;True;0;0;0;False;0;False;1,0.97,0.92,1;1,0.97,0.92,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;19;800,40;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1100,40;Float;False;True;-1;2;ASEMaterialInspector;0;2;PP_FlashBang;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;7;0;5;0
WireConnection;7;1;6;0
WireConnection;4;0;3;0
WireConnection;9;0;7;0
WireConnection;9;1;8;0
WireConnection;11;0;9;0
WireConnection;11;1;10;0
WireConnection;14;0;12;0
WireConnection;14;1;11;0
WireConnection;14;2;13;0
WireConnection;15;0;14;0
WireConnection;19;0;16;0
WireConnection;19;1;17;0
WireConnection;19;2;18;0
WireConnection;0;0;19;0
ASEEND*/
//CHKSM=CB5C0E10E641CC27D42B97B2598541843B6BAD9D