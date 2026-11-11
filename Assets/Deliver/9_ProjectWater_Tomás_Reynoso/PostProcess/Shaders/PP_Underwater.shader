// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PP_Underwater"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_Underwater("Underwater", Range( 0 , 1)) = 0
		_TintColor("TintColor", Color) = (0.15,0.55,0.8,1)
		_TintAmount("TintAmount", Range( 0 , 1)) = 0.6
		_FogColor("FogColor", Color) = (0.02,0.18,0.3,1)
		_FogStart("FogStart", Range( 0 , 50)) = 1
		_FogDistance("FogDistance", Range( 0.1 , 100)) = 25
		_FogDensity("FogDensity", Range( 0 , 1)) = 0.95

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
			
			uniform float4 _TintColor;
			uniform float _TintAmount;
			uniform float4 _FogColor;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _FogStart;
			uniform float _FogDistance;
			uniform float _FogDensity;
			uniform float _Underwater;


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
				float4 colorEscena17 = tex2D( _MainTex, texCoord2 );
				float4 lerpResult32 = lerp( colorEscena17 , ( colorEscena17 * _TintColor ) , _TintAmount);
				float2 texCoord47 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float eyeDepth19 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, float4( texCoord47, 0.0 , 0.0 ).xy ));
				float niebla27 = ( saturate( ( ( eyeDepth19 - _FogStart ) / _FogDistance ) ) * _FogDensity );
				float4 lerpResult35 = lerp( lerpResult32 , _FogColor , niebla27);
				float4 lerpResult37 = lerp( colorEscena17 , lerpResult35 , _Underwater);
				

				finalColor = lerpResult37;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
289;72;903;544.5;898.2023;529.7787;2.560516;False;False
Node;AmplifyShaderEditor.CommentaryNode;44;-1637.368,64.73396;Inherit;False;1811.732;547.1974;PROFUNDIDAD;10;27;46;26;25;24;23;22;21;19;47;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-1587.368,164.734;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;42;-778.879,-377.207;Inherit;False;1013.212;367.0627;Color de la escena;4;17;18;2;1;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenDepthNode;19;-1337.368,164.734;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-1337.368,284.7341;Inherit;False;Property;_FogStart;FogStart;4;0;Create;True;0;0;0;False;0;False;1;1;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;1;-728.8789,-327.207;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-728.8789,-177.2072;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-1037.368,214.734;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1037.368,364.7341;Inherit;False;Property;_FogDistance;FogDistance;5;0;Create;True;0;0;0;False;0;False;25;25;0.1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;18;-378.879,-277.207;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;24;-787.368,264.7341;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;45;300,-400;Inherit;False;1426.11;739.1067;TINTE AZUL+FOG;11;37;12;36;35;32;34;33;29;31;28;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;21.12105,-277.207;Inherit;False;colorEscena;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;25;-587.368,264.7341;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-587.368,414.7341;Inherit;False;Property;_FogDensity;FogDensity;6;0;Create;True;0;0;0;False;0;False;0.95;0.95;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-287.3679,314.7341;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;380.149,-305.5217;Inherit;False;17;colorEscena;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;28;380.149,-205.5218;Inherit;False;Property;_TintColor;TintColor;1;0;Create;True;0;0;0;False;0;False;0.15,0.55,0.8,1;0.15,0.55,0.8,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;680.1492,-205.2733;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-37.36787,314.7341;Inherit;False;niebla;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;536.9406,-30.14909;Inherit;False;Property;_TintAmount;TintAmount;2;0;Create;True;0;0;0;False;0;False;0.6;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;33;871.8595,-22.57238;Inherit;False;Property;_FogColor;FogColor;3;0;Create;True;0;0;0;False;0;False;0.02,0.18,0.3,1;0.02,0.18,0.3,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;32;930.1492,-305.5217;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;939.9889,155.2117;Inherit;False;27;niebla;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;35;1150,0;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;1150,-250;Inherit;False;17;colorEscena;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;12;1236.885,197.7084;Inherit;False;Property;_Underwater;Underwater;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;37;1450,-100;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1900,-100;Float;False;True;-1;2;ASEMaterialInspector;0;2;PP_Underwater;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;19;0;47;0
WireConnection;22;0;19;0
WireConnection;22;1;21;0
WireConnection;18;0;1;0
WireConnection;18;1;2;0
WireConnection;24;0;22;0
WireConnection;24;1;23;0
WireConnection;17;0;18;0
WireConnection;25;0;24;0
WireConnection;46;0;25;0
WireConnection;46;1;26;0
WireConnection;31;0;30;0
WireConnection;31;1;28;0
WireConnection;27;0;46;0
WireConnection;32;0;30;0
WireConnection;32;1;31;0
WireConnection;32;2;29;0
WireConnection;35;0;32;0
WireConnection;35;1;33;0
WireConnection;35;2;34;0
WireConnection;37;0;36;0
WireConnection;37;1;35;0
WireConnection;37;2;12;0
WireConnection;0;0;37;0
ASEEND*/
//CHKSM=91EB3FBC9BEF55D2F0D74881C81BFBAEE90A80F7