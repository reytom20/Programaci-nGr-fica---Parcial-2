// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Agua"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		[Header(ASPECTO GENERAL)]_WaterLevel("WaterLevel", Float) = 0
		_WaterTransparency("WaterTransparency", Range( 0 , 1)) = 0.3
		[Header(OLAS)]_WaveFrequency("WaveFrequency", Float) = 0
		_WaveSpeed("WaveSpeed", Vector) = (0,0,0,0)
		_WaveAmplitude("WaveAmplitude", Float) = 0
		[Header(RUIDO)]_NoiseScale("NoiseScale", Float) = 0
		_NoiseSpeed("NoiseSpeed", Float) = 0.15
		_NoiseAmplitude("NoiseAmplitude", Float) = 0
		[Header(DISTORSION AGUA)]_DistortionAmount("DistortionAmount", Range( 0 , 1)) = 0.05
		_MoveDistortionSpeed("MoveDistortionSpeed", Vector) = (0,0,0,0)
		[Header(DISTORSION FONDO)]_DistortionFrequency("DistortionFrequency", Range( 25 , 50)) = 0
		_DistortionSpeed("DistortionSpeed", Float) = 0
		_DistortionStrength("DistortionStrength", Range( 0 , 0.01)) = 0
		_RefractionBlend("RefractionBlend", Range( 0 , 1)) = 0.5
		[Header(REACCION)]_ImpactPosition("ImpactPosition", Float) = 0
		_SinkingStrength("SinkingStrength", Float) = 0
		_SinkingProgress("SinkingProgress", Range( 0 , 1)) = 0
		_SinkingWidth("SinkingWidth", Float) = 0
		[Header(SPLASH)]_SplashPosition("SplashPosition", Float) = 0
		_SplashThickness("SplashThickness", Float) = 0
		_SplashStrength("SplashStrength", Float) = 0
		_SplashProgress("SplashProgress", Range( 0 , 1)) = 0
		_SplashWidth("SplashWidth", Float) = 0
		_SplashActive("SplashActive", Float) = 0
		[Header(SALIDA)]_ExitPosition("ExitPosition", Float) = 0
		_ExitWidth("ExitWidth", Float) = 0
		_ExitStrength("ExitStrength", Float) = 0
		_ExitProgress("ExitProgress", Range( 0 , 1)) = 0
		[Header(TEXTURAS)]_Agua("Agua", 2D) = "white" {}
		_Texture1("Texture 1", 2D) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
		GrabPass{ }

		Pass
		{
		CGPROGRAM
			#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
			#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
			#else
			#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
			#endif

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityStandardUtils.cginc"


			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord1 : TEXCOORD1;
			};
			
			uniform fixed4 _Color;
			uniform float _EnableExternalAlpha;
			uniform sampler2D _MainTex;
			uniform sampler2D _AlphaTex;
			uniform sampler2D _Agua;
			uniform sampler2D _Texture1;
			uniform float2 _MoveDistortionSpeed;
			uniform float4 _Agua_ST;
			uniform float _DistortionAmount;
			uniform float _WaterLevel;
			uniform float _WaveFrequency;
			uniform float2 _WaveSpeed;
			uniform float _WaveAmplitude;
			uniform float _NoiseScale;
			uniform float _NoiseSpeed;
			uniform float _NoiseAmplitude;
			uniform float _ImpactPosition;
			uniform float _SinkingWidth;
			uniform float _SinkingStrength;
			uniform float _SinkingProgress;
			uniform float _SplashPosition;
			uniform float _SplashProgress;
			uniform float _SplashWidth;
			uniform float _SplashThickness;
			uniform float _SplashStrength;
			uniform float _SplashActive;
			uniform float _ExitPosition;
			uniform float _ExitWidth;
			uniform float _ExitStrength;
			uniform float _ExitProgress;
			uniform float _WaterTransparency;
			ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
			uniform float _DistortionFrequency;
			uniform float _DistortionSpeed;
			uniform float _DistortionStrength;
			uniform float _RefractionBlend;
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			
			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				float4 ase_clipPos = UnityObjectToClipPos(IN.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				OUT.ase_texcoord1 = screenPos;
				
				
				IN.vertex.xyz +=  float3(0,0,0) ; 
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				fixed4 alpha = tex2D (_AlphaTex, uv);
				color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
#endif //ETC1_EXTERNAL_ALPHA

				return color;
			}
			
			fixed4 frag(v2f IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float TimeVar197_g1 = _Time.y;
				float2 uv_Agua = IN.texcoord.xy * _Agua_ST.xy + _Agua_ST.zw;
				float2 MainUvs222_g1 = uv_Agua;
				float4 tex2DNode65_g1 = tex2D( _Texture1, ( ( _MoveDistortionSpeed * TimeVar197_g1 ) + MainUvs222_g1 ) );
				float4 appendResult82_g1 = (float4(0.0 , tex2DNode65_g1.g , 0.0 , tex2DNode65_g1.r));
				float2 temp_output_84_0_g1 = (UnpackScaleNormal( appendResult82_g1, _DistortionAmount )).xy;
				float2 temp_output_71_0_g1 = ( temp_output_84_0_g1 + MainUvs222_g1 );
				float4 tex2DNode96_g1 = tex2D( _Agua, temp_output_71_0_g1 );
				float4 break33 = tex2DNode96_g1;
				float2 texCoord12 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord66 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float simplePerlin2D73 = snoise( ( ( texCoord66 * _NoiseScale ) + ( _Time.y * _NoiseSpeed ) ) );
				simplePerlin2D73 = simplePerlin2D73*0.5 + 0.5;
				float Noise77 = ( ( simplePerlin2D73 - 0.5 ) * _NoiseAmplitude );
				float2 texCoord115 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult127 = smoothstep( 0.0 , 1.0 , saturate( ( abs( ( (texCoord115).x - _ImpactPosition ) ) / _SinkingWidth ) ));
				float Sinking123 = ( ( ( 1.0 - smoothstepResult127 ) * _SinkingStrength ) * _SinkingProgress );
				float2 texCoord134 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult146 = smoothstep( 0.0 , 1.0 , saturate( ( abs( ( abs( ( (texCoord134).x - _SplashPosition ) ) - ( _SplashProgress * _SplashWidth ) ) ) / _SplashThickness ) ));
				float SplashOffset156 = ( ( ( 1.0 - smoothstepResult146 ) * ( ( 1.0 - _SplashProgress ) * _SplashStrength ) ) * _SplashActive );
				float smoothstepResult171 = smoothstep( 0.0 , 1.0 , saturate( ( abs( ( (texCoord134).x - _ExitPosition ) ) / _ExitWidth ) ));
				float ExitOffset175 = ( ( 1.0 - smoothstepResult171 ) * ( _ExitStrength * _ExitProgress ) );
				float WaterSurfaceMask106 = step( (texCoord12).y , ( ( ( ( ( ( _WaterLevel + ( sin( ( ( (texCoord12).x * _WaveFrequency ) + ( _Time.y * _WaveSpeed.x ) ) ) * _WaveAmplitude ) ) + ( sin( ( _Time.y * _WaveSpeed.y ) ) * 0.02 ) ) + Noise77 ) - Sinking123 ) + SplashOffset156 ) + ExitOffset175 ) );
				float temp_output_50_0 = ( ( break33.a * WaterSurfaceMask106 ) * _WaterTransparency );
				float4 appendResult34 = (float4(break33.r , break33.g , break33.b , temp_output_50_0));
				float4 screenPos = IN.ase_texcoord1;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 appendResult94 = (float2(( ase_grabScreenPosNorm.r + ( sin( ( ( ase_grabScreenPosNorm.g * _DistortionFrequency ) + ( _Time.y * _DistortionSpeed ) ) ) * _DistortionStrength ) ) , ase_grabScreenPosNorm.g));
				float2 DistortedScreenUV101 = appendResult94;
				float4 screenColor81 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,DistortedScreenUV101);
				float4 lerpResult84 = lerp( appendResult34 , screenColor81 , _RefractionBlend);
				float4 appendResult99 = (float4(lerpResult84.rgb , temp_output_50_0));
				
				fixed4 c = appendResult99;
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
295;73;1041;512;2870.487;775.7155;2.12862;False;False
Node;AmplifyShaderEditor.CommentaryNode;157;-3071.333,2217.506;Inherit;False;2601.031;689.7433;SPLASH;16;156;161;160;155;146;149;152;148;154;145;153;144;143;141;138;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;124;-3036.473,1733.534;Inherit;False;2134.87;309.394;Hundimiento;15;123;129;128;122;113;121;127;120;119;118;114;117;116;112;115;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;138;-2797.607,2267.506;Inherit;False;547.2585;232.312;Distancia horizontal al centro del impacto;4;137;130;136;135;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;134;-3054.382,2599.237;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;115;-2986.473,1783.534;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;130;-2739.986,2418.818;Inherit;False;Property;_SplashPosition;SplashPosition;25;1;[Header];Create;True;1;SPLASH;0;0;False;0;False;0;0.8074347;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;135;-2747.607,2317.506;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;141;-2777.266,2515.033;Inherit;False;521.3983;244.5874;Radio de la expansion del splash;3;131;132;139;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;116;-2765.458,1798.629;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-2739.809,1897.44;Inherit;False;Property;_ImpactPosition;ImpactPosition;14;1;[Header];Create;True;1;REACCION;0;0;False;0;False;0;0.8074347;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;136;-2541.347,2327.101;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;132;-2713.322,2658.942;Inherit;False;Property;_SplashWidth;SplashWidth;29;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-2727.266,2565.033;Inherit;False;Property;_SplashProgress;SplashProgress;28;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-2417.867,2591.121;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;143;-2194.393,2317.348;Inherit;False;350.8251;185;Distancia a la cresta de la onda del splash;2;140;142;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;117;-2502.299,1828.825;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;137;-2392.348,2328.101;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;78;-2512.21,-413.1832;Inherit;False;1464.543;462.8422;ruido OLAS;12;67;66;71;69;72;68;70;73;74;75;76;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;69;-2432.077,-139.7141;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;118;-2349.299,1832.825;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;24;-2710.943,759.1685;Inherit;False;253.1127;147.6426;uv.x;1;13;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;176;-2815.043,2941.519;Inherit;False;1642.632;398.5896;elevacion del agua cuando sale un objeto;16;175;174;163;162;173;172;171;170;169;165;167;166;164;168;179;180;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-2424.215,-237.9805;Inherit;False;Property;_NoiseScale;NoiseScale;5;1;[Header];Create;True;1;RUIDO;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-2377.053,1922.237;Inherit;False;Property;_SinkingWidth;SinkingWidth;24;0;Create;True;0;0;0;False;0;False;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;140;-2144.393,2367.348;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-2462.21,-66.3421;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;6;0;Create;True;0;0;0;False;0;False;0.15;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-3134.551,892.3417;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;66;-2461.979,-363.1833;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-2160.856,-344.1099;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;13;-2660.943,814.2686;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;119;-2207.299,1833.825;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2698.527,944.6359;Inherit;False;Property;_WaveFrequency;WaveFrequency;2;1;[Header];Create;True;1;OLAS;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-2043.514,2508.04;Inherit;False;Property;_SplashThickness;SplashThickness;26;0;Create;True;0;0;0;False;0;False;0;0.045;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;15;-2681.578,1060.266;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;164;-2752.192,3136.519;Inherit;False;Property;_ExitPosition;ExitPosition;31;1;[Header];Create;True;1;SALIDA;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;142;-1993.567,2368.854;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;45;-2387.111,695.4326;Inherit;False;652.7225;325.7186;Movimiento horizontal OLAS;6;21;18;17;16;22;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-2176.579,-193.4335;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;168;-2773.146,3043.377;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;40;-2608.73,1145.157;Inherit;False;Property;_WaveSpeed;WaveSpeed;3;0;Create;True;0;0;0;False;0;False;0,0;2,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;166;-2553.19,3076.302;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;-1955.145,-278.5976;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-2360.398,914.2263;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;153;-2422.255,2794.468;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;120;-2061.875,1835.91;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;145;-1804.409,2403;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2376.645,745.4326;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;165;-2390.794,3255.655;Inherit;False;Property;_ExitWidth;ExitWidth;32;0;Create;True;0;0;0;False;0;False;0;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;167;-2367.213,3057.759;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;154;-1689.587,2807.367;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;46;-2366.423,1308.155;Inherit;False;540.0364;292.6381;oscilación vertical OLAS;4;39;42;37;41;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SmoothstepOpNode;127;-1916.435,1827.236;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;36;-2541.285,1511.377;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;73;-1825.434,-283.8378;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;152;-1511.865,2666.577;Inherit;False;437.5619;217.0391;Altura maxima de la onda;3;133;151;150;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;148;-1680.023,2409.119;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-2156.612,838.5687;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;169;-2197.439,3025.465;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-1461.865,2798.477;Inherit;False;Property;_SplashStrength;SplashStrength;27;0;Create;True;0;0;0;False;0;False;0;0.09;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1666.896,-154.1873;Inherit;False;Property;_NoiseAmplitude;NoiseAmplitude;7;0;Create;True;0;0;0;False;0;False;0;0.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;149;-1374.191,2363.917;Inherit;False;330.3073;142.5891;devuelve 1 en el centro de la cresta, 0 fuera;1;147;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;108;-1699.838,916.2728;Inherit;False;621.1187;232.1293;Cálculo de la superficie (altura, combinacion x e y);5;26;80;79;38;27;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;150;-1433.915,2720.288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;146;-1527.084,2407.079;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;17;-2006.173,840.2404;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;121;-1722.11,1820.783;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-1747.576,1892.716;Inherit;False;Property;_SinkingStrength;SinkingStrength;15;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;74;-1602.692,-272.0452;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2083.25,946.661;Inherit;False;Property;_WaveAmplitude;WaveAmplitude;4;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-2316.423,1358.155;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;170;-2057.252,3026.76;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-1223.247,2716.577;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-1421.881,-259.7645;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1856.856,843.2045;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-1580.589,1960.977;Inherit;False;Property;_SinkingProgress;SinkingProgress;23;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;37;-2121.244,1386.387;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-2174.555,1484.793;Inherit;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;0;False;0;False;0.02;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1671.867,1034.712;Inherit;False;Property;_WaterLevel;WaterLevel;0;1;[Header];Create;True;1;ASPECTO GENERAL;0;0;False;0;False;0;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;-1523.873,1823.462;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;147;-1279.086,2418.295;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;171;-1912.141,3018.656;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-1942.028,3152.939;Inherit;False;Property;_ExitStrength;ExitStrength;33;0;Create;True;0;0;0;False;0;False;0;0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-1500.012,957.8322;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-2011.511,3237.594;Inherit;False;Property;_ExitProgress;ExitProgress;34;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-998.1492,2577.635;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-1271.664,-255.0765;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1988.388,1422.737;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;-1262.898,1818.128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;-1006.297,2684.96;Inherit;False;Property;_SplashActive;SplashActive;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-1366.346,962.9081;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;172;-1725.85,3036.564;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;173;-1712.125,3165.987;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;123;-1094.514,1818.544;Float;False;Sinking;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;-822.8344,2552.924;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-1394.517,1070.382;Inherit;False;77;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;102;-2628.005,64.31802;Inherit;False;1736.482;583.6083;Distorsión UV del fondo;13;88;86;87;97;98;83;89;90;91;92;93;94;101;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;25;-2873.22,1305.964;Inherit;False;256.1723;155.2915;uv.y;1;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-2563.745,499.0541;Inherit;False;Property;_DistortionSpeed;DistortionSpeed;11;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;86;-2559.756,421.4631;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-2517.659,309.148;Inherit;False;Property;_DistortionFrequency;DistortionFrequency;10;1;[Header];Create;True;1;DISTORSION FONDO;0;0;False;0;False;0;30;25;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;83;-2517.215,114.318;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;126;-1232.372,1169.489;Inherit;False;123;Sinking;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;23;-2823.219,1355.964;Inherit;False;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;156;-658.1591,2550.544;Float;False;SplashOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;174;-1519.949,3089.51;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-1220.172,1007.899;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-2238.405,268.946;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;48;-2326.093,1202.785;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-2354.565,421.0272;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;-1370.917,3093.432;Inherit;False;ExitOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;125;-1020.118,1035.321;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;158;-1059.893,1237.533;Inherit;False;156;SplashOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;159;-819.2068,1060.731;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;105;-1741.36,1191.217;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;89;-2073.09,372.3629;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;178;-802.4871,1176.495;Inherit;False;175;ExitOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-2071.434,475.4648;Inherit;False;Property;_DistortionStrength;DistortionStrength;12;0;Create;True;0;0;0;False;0;False;0;0.01;0;0.01;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;90;-1936.831,378.5287;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;177;-593.5562,1072.953;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;109;-941.2216,1335.94;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;43;-540.7951,-242.3711;Inherit;False;798;772.4826;Distorsión animada del agua;6;11;6;4;5;1;8;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;110;-361.3937,1001.046;Inherit;False;447.8374;208.142;máscara del agua;2;106;28;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StepOpNode;28;-311.3932,1051.046;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;6;-475.7948,2.629082;Inherit;True;Property;_Texture1;Texture 1;36;0;Create;True;0;0;0;False;0;False;301efde3a1ab4734e858532b281b44fe;301efde3a1ab4734e858532b281b44fe;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;5;-490.7948,-192.3709;Inherit;True;Property;_Agua;Agua;35;1;[Header];Create;True;1;TEXTURAS;0;0;False;0;False;82b77ae84bd708241b7a49816c40f93d;82b77ae84bd708241b7a49816c40f93d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;4;-487.7948,209.6294;Inherit;False;Property;_DistortionAmount;DistortionAmount;8;1;[Header];Create;True;1;DISTORSION AGUA;0;0;False;0;False;0.05;0.05;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;11;-456.9538,288.7732;Inherit;False;Property;_MoveDistortionSpeed;MoveDistortionSpeed;9;0;Create;True;0;0;0;False;0;False;0,0;0.02,0.02;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-1787.31,378.6984;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;8;-400.8588,419.1114;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1;-81.79382,-124.3708;Inherit;False;UI-Sprite Effect Layer;16;;1;789bf62641c5cfe4ab7126850acc22b8;18,74,0,204,0,191,0,225,0,242,0,237,0,249,0,186,0,177,0,182,1,229,0,92,0,98,0,234,0,126,0,129,1,130,0,31,0;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-1577.999,197.9143;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;47;783.5708,-24.83518;Inherit;False;1078.521;519.5778;mask + transparencia;6;49;32;50;34;33;107;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-158.555,1093.188;Inherit;False;WaterSurfaceMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;1013.966,352.6114;Inherit;False;106;WaterSurfaceMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;94;-1337.07,262.327;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;33;795.3737,109.7907;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;111;1321.461,508.2832;Inherit;False;542.8811;339.0411;captura del fondo;3;104;81;85;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;1321.868,185.1571;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;1271.549,403.8131;Inherit;False;Property;_WaterTransparency;WaterTransparency;1;0;Create;True;1;ASPECTO GENERAL;0;0;False;0;False;0.3;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-1139.523,262.3064;Inherit;False;DistortedScreenUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;1564.469,240.1428;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;1371.461,558.2837;Inherit;False;101;DistortedScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;81;1607.565,559.4221;Inherit;False;Global;_GrabScreen0;Grab Screen 0;13;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;34;1732.948,50.85968;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;85;1564.342,731.3248;Inherit;False;Property;_RefractionBlend;RefractionBlend;13;0;Create;True;0;0;0;False;0;False;0.5;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;84;2033.953,257.1118;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;100;2055.166,454.659;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;99;2558.935,366.6599;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2794.169,378.4577;Float;False;True;-1;2;ASEMaterialInspector;0;6;Agua;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.CommentaryNode;179;-2792.355,2990.139;Inherit;False;547.5928;247.7979;distancia de c pixel del agua y pos del objeto;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;103;-2184.944,-562.8098;Inherit;False;647.8616;100;Auxiliary Calculations;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;180;-2224.751,2983.568;Inherit;False;642.2496;151.9556;elevacion, su intensidad disminuye hacia los bordes;0;;1,1,1,1;0;0
WireConnection;135;0;134;0
WireConnection;116;0;115;0
WireConnection;136;0;135;0
WireConnection;136;1;130;0
WireConnection;139;0;131;0
WireConnection;139;1;132;0
WireConnection;117;0;116;0
WireConnection;117;1;112;0
WireConnection;137;0;136;0
WireConnection;118;0;117;0
WireConnection;140;0;137;0
WireConnection;140;1;139;0
WireConnection;67;0;66;0
WireConnection;67;1;71;0
WireConnection;13;0;12;0
WireConnection;119;0;118;0
WireConnection;119;1;114;0
WireConnection;142;0;140;0
WireConnection;68;0;69;0
WireConnection;68;1;72;0
WireConnection;168;0;134;0
WireConnection;166;0;168;0
WireConnection;166;1;164;0
WireConnection;70;0;67;0
WireConnection;70;1;68;0
WireConnection;22;0;15;0
WireConnection;22;1;40;1
WireConnection;153;0;131;0
WireConnection;120;0;119;0
WireConnection;145;0;142;0
WireConnection;145;1;144;0
WireConnection;14;0;13;0
WireConnection;14;1;19;0
WireConnection;167;0;166;0
WireConnection;154;0;153;0
WireConnection;127;0;120;0
WireConnection;73;0;70;0
WireConnection;148;0;145;0
WireConnection;16;0;14;0
WireConnection;16;1;22;0
WireConnection;169;0;167;0
WireConnection;169;1;165;0
WireConnection;150;0;154;0
WireConnection;146;0;148;0
WireConnection;17;0;16;0
WireConnection;121;0;127;0
WireConnection;74;0;73;0
WireConnection;39;0;36;0
WireConnection;39;1;40;2
WireConnection;170;0;169;0
WireConnection;151;0;150;0
WireConnection;151;1;133;0
WireConnection;75;0;74;0
WireConnection;75;1;76;0
WireConnection;18;0;17;0
WireConnection;18;1;21;0
WireConnection;37;0;39;0
WireConnection;122;0;121;0
WireConnection;122;1;113;0
WireConnection;147;0;146;0
WireConnection;171;0;170;0
WireConnection;27;0;26;0
WireConnection;27;1;18;0
WireConnection;155;0;147;0
WireConnection;155;1;151;0
WireConnection;77;0;75;0
WireConnection;41;0;37;0
WireConnection;41;1;42;0
WireConnection;129;0;122;0
WireConnection;129;1;128;0
WireConnection;38;0;27;0
WireConnection;38;1;41;0
WireConnection;172;0;171;0
WireConnection;173;0;162;0
WireConnection;173;1;163;0
WireConnection;123;0;129;0
WireConnection;161;0;155;0
WireConnection;161;1;160;0
WireConnection;23;0;12;0
WireConnection;156;0;161;0
WireConnection;174;0;172;0
WireConnection;174;1;173;0
WireConnection;79;0;38;0
WireConnection;79;1;80;0
WireConnection;98;0;83;2
WireConnection;98;1;97;0
WireConnection;48;0;23;0
WireConnection;87;0;86;0
WireConnection;87;1;88;0
WireConnection;175;0;174;0
WireConnection;125;0;79;0
WireConnection;125;1;126;0
WireConnection;159;0;125;0
WireConnection;159;1;158;0
WireConnection;105;0;48;0
WireConnection;89;0;98;0
WireConnection;89;1;87;0
WireConnection;90;0;89;0
WireConnection;177;0;159;0
WireConnection;177;1;178;0
WireConnection;109;0;105;0
WireConnection;28;0;109;0
WireConnection;28;1;177;0
WireConnection;92;0;90;0
WireConnection;92;1;91;0
WireConnection;1;37;5;0
WireConnection;1;75;6;0
WireConnection;1;80;4;0
WireConnection;1;183;11;0
WireConnection;1;40;8;0
WireConnection;93;0;83;1
WireConnection;93;1;92;0
WireConnection;106;0;28;0
WireConnection;94;0;93;0
WireConnection;94;1;83;2
WireConnection;33;0;1;0
WireConnection;32;0;33;3
WireConnection;32;1;107;0
WireConnection;101;0;94;0
WireConnection;50;0;32;0
WireConnection;50;1;49;0
WireConnection;81;0;104;0
WireConnection;34;0;33;0
WireConnection;34;1;33;1
WireConnection;34;2;33;2
WireConnection;34;3;50;0
WireConnection;84;0;34;0
WireConnection;84;1;81;0
WireConnection;84;2;85;0
WireConnection;100;0;50;0
WireConnection;99;0;84;0
WireConnection;99;3;100;0
WireConnection;0;0;99;0
ASEEND*/
//CHKSM=6B261BA5FEA6E1ADF62CFDF55CEB21429E1CBC95