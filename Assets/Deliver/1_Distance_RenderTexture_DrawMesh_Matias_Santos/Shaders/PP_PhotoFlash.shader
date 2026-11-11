// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PP_PhotoFlash"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_Shutter("Shutter", Range( 0 , 1)) = 0
		_ShutterSoftness("ShutterSoftness", Range( 0 , 0.3)) = 0.05
		_ShutterColor("ShutterColor", Color) = (0,0,0,1)
		_FlashColor("FlashColor", Color) = (1,1,1,1)
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
			#include "UnityShaderVariables.cginc"


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
			
			uniform float4 _ShutterColor;
			uniform float _Shutter;
			uniform float _ShutterSoftness;
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
				float lerpResult18 = lerp( 1.2 , -0.1 , _Shutter);
				float2 texCoord5 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult10 = (float4(( _ScreenParams.x / _ScreenParams.y ) , 1.0 , 0.0 , 0.0));
				float smoothstepResult21 = smoothstep( lerpResult18 , ( lerpResult18 + _ShutterSoftness ) , distance( ( float4( ( texCoord5 - float2( 0.5,0.5 ) ), 0.0 , 0.0 ) * appendResult10 ) , float4( float2( 0,0 ), 0.0 , 0.0 ) ));
				float4 lerpResult24 = lerp( pantalla4 , _ShutterColor , smoothstepResult21);
				float4 conObturador25 = lerpResult24;
				float4 lerpResult29 = lerp( conObturador25 , _FlashColor , _Flash);
				

				finalColor = lerpResult29;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
307.5;72;944;457.5;-5.366211;546.6516;1.902761;False;False
Node;AmplifyShaderEditor.CommentaryNode;31;-1750,-530;Inherit;False;2274;825;Lente Camara;21;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenParams;7;-1610.276,20;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;6;-1700,-120.3262;Inherit;False;Constant;_Centro;Centro;0;0;Create;True;0;0;0;False;0;False;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1700,-278.7954;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;30;-1750,-1060;Inherit;False;974;326;Pantalla;4;1;2;3;4;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;8;-1350,40;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1350,180;Inherit;False;Constant;_Uno1;Uno 1;0;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-950,-480;Inherit;False;Constant;_Abierto12;Abierto 1.2;1;0;Create;True;0;0;0;False;0;False;1.2;1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;11;-1350,-230;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1700,-890;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;1;-1700,-1010;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-1055.279,-294.7214;Inherit;False;Property;_Shutter;Shutter;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;-1150,80;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1012.088,-375.8908;Inherit;False;Constant;_Cerrado01;Cerrado -0.1;1;0;Create;True;0;0;0;False;0;False;-0.1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;13;-950,-40;Inherit;False;Constant;_Origen00;Origen (0,0);0;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;3;-1350,-1010;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;19;-700,-270;Inherit;False;Property;_ShutterSoftness;ShutterSoftness;1;0;Create;True;0;0;0;False;0;False;0.05;0.05;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;18;-700,-420;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-950,-180;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;4;-1000,-1010;Inherit;False;pantalla;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceOpNode;14;-700,-150;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-374.4153,-362.3935;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;21;-250,-220;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-250,-420;Inherit;False;4;pantalla;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;23;-250,-80;Inherit;False;Property;_ShutterColor;ShutterColor;2;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;24;20.16046,-262.2953;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;32;650,-310;Inherit;False;532;465;flash;4;26;27;28;29;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;203.5953,-264.5907;Inherit;False;conObturador;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;27;700,-140;Inherit;False;Property;_FlashColor;FlashColor;3;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;26;700,-260;Inherit;False;25;conObturador;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;28;700,40;Inherit;False;Property;_Flash;Flash;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;29;1000,-220;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1300,-220;Float;False;True;-1;2;ASEMaterialInspector;0;2;PP_PhotoFlash;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;8;0;7;1
WireConnection;8;1;7;2
WireConnection;11;0;5;0
WireConnection;11;1;6;0
WireConnection;10;0;8;0
WireConnection;10;1;9;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;18;2;15;0
WireConnection;12;0;11;0
WireConnection;12;1;10;0
WireConnection;4;0;3;0
WireConnection;14;0;12;0
WireConnection;14;1;13;0
WireConnection;20;0;18;0
WireConnection;20;1;19;0
WireConnection;21;0;14;0
WireConnection;21;1;18;0
WireConnection;21;2;20;0
WireConnection;24;0;22;0
WireConnection;24;1;23;0
WireConnection;24;2;21;0
WireConnection;25;0;24;0
WireConnection;29;0;26;0
WireConnection;29;1;27;0
WireConnection;29;2;28;0
WireConnection;0;0;29;0
ASEEND*/
//CHKSM=C4D44E47C1F3E3FC535FDED7DDA0C810E3EBBEB7