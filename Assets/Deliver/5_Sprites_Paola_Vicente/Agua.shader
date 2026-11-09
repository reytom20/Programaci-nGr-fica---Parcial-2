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
		_WaveFrequency("WaveFrequency", Float) = 0
		_WaveSpeed("WaveSpeed", Vector) = (0,0,0,0)
		_WaterLevel("WaterLevel", Float) = 0
		_WaterTransparency("WaterTransparency", Range( 0 , 1)) = 0.3
		_NoiseScale("NoiseScale", Float) = 0
		_NoiseSpeed("NoiseSpeed", Float) = 0.15
		_MoveDistortionSpeed("MoveDistortionSpeed", Vector) = (0,0,0,0)
		_RefractionBlend("RefractionBlend", Range( 0 , 1)) = 0.5
		_DistortionSpeed("DistortionSpeed", Float) = 0
		_WaveAmplitude("WaveAmplitude", Float) = 0
		_ImpactPosition("ImpactPosition", Float) = 0
		_DistortionFrequency("DistortionFrequency", Range( 25 , 50)) = 0
		_DistortionStrength("DistortionStrength", Range( 0 , 0.01)) = 0
		_ImpactTime("ImpactTime", Float) = 0
		_NoiseAmplitude("NoiseAmplitude", Float) = 0
		_ImpactStrength("ImpactStrength", Float) = 0
		_DistortionAmount("DistortionAmount", Range( 0 , 1)) = 0.05
		_ImpactFrequency("ImpactFrequency", Float) = 0
		_ImpactSpeed("ImpactSpeed", Float) = 0
		_ImpactObjectPosition("ImpactObjectPosition", Vector) = (0,0,0,0)
		_ObjectWaveStrength("ObjectWaveStrength", Float) = 0
		_InteractionRadius("InteractionRadius", Float) = 0
		_Texture1("Texture 1", 2D) = "white" {}
		_ImpactDecay("ImpactDecay", Float) = 0
		_Agua("Agua", 2D) = "white" {}
		_ImpactFalloff("ImpactFalloff", Float) = 5

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
				float4 ase_texcoord2 : TEXCOORD2;
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
			uniform float _ImpactFalloff;
			uniform float _ImpactFrequency;
			uniform float _ImpactTime;
			uniform float _ImpactSpeed;
			uniform float _ImpactDecay;
			uniform float _ImpactStrength;
			uniform float3 _ImpactObjectPosition;
			uniform float _InteractionRadius;
			uniform float _ObjectWaveStrength;
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
				float3 ase_worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;
				OUT.ase_texcoord1.xyz = ase_worldPos;
				float4 ase_clipPos = UnityObjectToClipPos(IN.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				OUT.ase_texcoord2 = screenPos;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				OUT.ase_texcoord1.w = 0;
				
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
				float temp_output_23_0 = (texCoord12).y;
				float2 texCoord66 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float simplePerlin2D73 = snoise( ( ( texCoord66 * _NoiseScale ) + ( _Time.y * _NoiseSpeed ) ) );
				simplePerlin2D73 = simplePerlin2D73*0.5 + 0.5;
				float Noise77 = ( ( simplePerlin2D73 - 0.5 ) * _NoiseAmplitude );
				float2 texCoord116 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_118_0 = abs( ( texCoord116.x - _ImpactPosition ) );
				float temp_output_120_0 = ( _Time.y - _ImpactTime );
				float WaveDistance189 = temp_output_118_0;
				float WaveTravel188 = ( max( temp_output_120_0 , 0.0 ) * _ImpactSpeed );
				float smoothstepResult194 = smoothstep( 0.0 , 0.08 , abs( ( WaveDistance189 - WaveTravel188 ) ));
				float WaveFrontMask196 = ( 1.0 - smoothstepResult194 );
				float ImpactWave139 = ( ( ( saturate( ( 1.0 - ( temp_output_118_0 * _ImpactFalloff ) ) ) * ( sin( ( ( temp_output_118_0 * _ImpactFrequency ) - ( temp_output_120_0 * _ImpactSpeed ) ) ) * saturate( ( 1.0 - ( temp_output_120_0 * _ImpactDecay ) ) ) ) ) * _ImpactStrength ) * WaveFrontMask196 );
				float3 ase_worldPos = IN.ase_texcoord1.xyz;
				float ObjectInfluence152 = saturate( ( 1.0 - ( distance( ase_worldPos , _ImpactObjectPosition ) / _InteractionRadius ) ) );
				float ObjectWave161 = ( ( sin( ( _Time.y * 8.0 ) ) * ObjectInfluence152 ) * _ObjectWaveStrength );
				float temp_output_163_0 = ( ( ( ( ( _WaterLevel + ( sin( ( ( (texCoord12).x * _WaveFrequency ) + ( _Time.y * _WaveSpeed.x ) ) ) * _WaveAmplitude ) ) + ( sin( ( _Time.y * _WaveSpeed.y ) ) * 0.02 ) ) + Noise77 ) + ImpactWave139 ) + ObjectWave161 );
				float WaterSurfaceMask106 = step( temp_output_23_0 , temp_output_163_0 );
				float temp_output_50_0 = ( ( break33.a * WaterSurfaceMask106 ) * _WaterTransparency );
				float4 appendResult34 = (float4(break33.r , break33.g , break33.b , temp_output_50_0));
				float4 screenPos = IN.ase_texcoord2;
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
363;73;1101;540;2037.175;194.0891;1.646689;False;False
Node;AmplifyShaderEditor.SimpleTimeNode;119;762.1638,2302.409;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;769.5644,2374.994;Inherit;False;Property;_ImpactTime;ImpactTime;20;0;Create;True;0;0;0;False;0;False;0;-100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;837.3688,2755.141;Inherit;False;Property;_ImpactSpeed;ImpactSpeed;25;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;185;1102.418,2645.397;Inherit;False;Constant;_Float2;Float 2;29;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;120;1005.408,2303.873;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;565.5203,2213.084;Inherit;False;Property;_ImpactPosition;ImpactPosition;17;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;116;530.2728,2075.375;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;184;1285.99,2637.324;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;187;1306.07,2777.052;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;117;833.8817,2100.966;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;1508.651,2631.019;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;118;1004.877,2110.273;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;188;1686.815,2682.55;Inherit;False;WaveTravel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;189;1078.15,1889.836;Inherit;False;WaveDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;1222.215,2474.443;Inherit;False;Property;_ImpactDecay;ImpactDecay;32;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;1074.94,2985.665;Inherit;False;189;WaveDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;945.5137,2211.086;Inherit;False;Property;_ImpactFrequency;ImpactFrequency;24;0;Create;True;0;0;0;False;0;False;0;40;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;191;1086.97,3067.089;Inherit;False;188;WaveTravel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;128;1230.665,2432.953;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;78;-2512.21,-413.1832;Inherit;False;1464.543;462.8422;ruido OLAS;12;67;66;71;69;72;68;70;73;74;75;76;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-2462.21,-66.3421;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;12;0;Create;True;0;0;0;False;0;False;0.15;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;24;-2710.943,759.1685;Inherit;False;253.1127;147.6426;uv.x;1;13;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-2424.215,-237.9805;Inherit;False;Property;_NoiseScale;NoiseScale;11;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-3134.551,892.3417;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;145;2232.612,2449.465;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;66;-2461.979,-363.1833;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;69;-2432.077,-139.7141;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;1207.386,2306.192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;147;2200.612,2605.465;Inherit;False;Property;_ImpactObjectPosition;ImpactObjectPosition;26;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;131;1723.353,1961.235;Inherit;False;Property;_ImpactFalloff;ImpactFalloff;34;0;Create;True;0;0;0;False;0;False;5;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;1425.665,2397.953;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;1185.112,2104.142;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;192;1380.946,3044.964;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;133;1189.415,2036.325;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;129;1567.665,2398.953;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;40;-2608.73,1145.157;Inherit;False;Property;_WaveSpeed;WaveSpeed;8;0;Create;True;0;0;0;False;0;False;0,0;2,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.AbsOpNode;193;1508.964,3041.801;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;146;2479.612,2461.465;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;148;2476.612,2565.465;Inherit;False;Property;_InteractionRadius;InteractionRadius;30;0;Create;True;0;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;15;-2681.578,1060.266;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;45;-2387.111,695.4326;Inherit;False;652.7225;325.7186;Movimiento horizontal OLAS;6;21;18;17;16;22;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2698.527,944.6359;Inherit;False;Property;_WaveFrequency;WaveFrequency;7;0;Create;True;0;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;124;1426.293,2094.718;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-2176.579,-193.4335;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;13;-2660.943,814.2686;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-2160.856,-344.1099;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;1952.737,1870.707;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;125;1581.293,2097.718;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;194;1727.078,2951.714;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.08;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;149;2721.612,2445.465;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-2360.398,914.2263;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2376.645,745.4326;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;-1955.145,-278.5976;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;130;1719.665,2399.953;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;134;2119.939,1875.835;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-2156.612,838.5687;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;36;-2541.285,1511.377;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;195;1944.651,3022.652;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;46;-2366.423,1308.155;Inherit;False;540.0364;292.6381;oscilación vertical OLAS;4;39;42;37;41;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;150;2853.612,2452.465;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;135;2283.945,1881.184;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;73;-1825.434,-283.8378;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;155;2803.885,2339.768;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;1915.857,2109.126;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;2476.176,2152.439;Inherit;False;Property;_ImpactStrength;ImpactStrength;22;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;74;-1602.692,-272.0452;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;108;-1699.838,916.2728;Inherit;False;621.1187;232.1293;Cálculo de la superficie (altura, combinacion x e y);5;26;80;79;38;27;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;196;2136.651,3084.652;Inherit;False;WaveFrontMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1666.896,-154.1873;Inherit;False;Property;_NoiseAmplitude;NoiseAmplitude;21;0;Create;True;0;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;17;-2006.173,840.2404;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-2316.423,1358.155;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;2531.334,2036.605;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;156;3001.054,2332.503;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;151;3011.612,2452.465;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2083.25,946.661;Inherit;False;Property;_WaveAmplitude;WaveAmplitude;16;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-2174.555,1484.793;Inherit;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;0;False;0;False;0.02;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1671.867,1034.712;Inherit;False;Property;_WaterLevel;WaterLevel;9;0;Create;True;0;0;0;False;0;False;0;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-1421.881,-259.7645;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;2817.478,2209.286;Inherit;False;196;WaveFrontMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;37;-2121.244,1386.387;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1856.856,843.2045;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;157;3202.489,2337.48;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;3171.612,2466.465;Inherit;False;ObjectInfluence;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;2720.997,2019.868;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;25;-2873.22,1305.964;Inherit;False;256.1723;155.2915;uv.y;1;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1988.388,1422.737;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;102;-2628.005,64.31802;Inherit;False;1736.482;583.6083;Distorsión UV del fondo;13;88;86;87;97;98;83;89;90;91;92;93;94;101;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-1500.012,957.8322;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-1271.664,-255.0765;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;3453.027,2460.518;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;3098.392,2157.449;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;159;3348.505,2616.529;Inherit;False;Property;_ObjectWaveStrength;ObjectWaveStrength;27;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;83;-2517.215,114.318;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;97;-2517.659,309.148;Inherit;False;Property;_DistortionFrequency;DistortionFrequency;18;0;Create;True;0;0;0;False;0;False;0;30;25;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-2563.745,499.0541;Inherit;False;Property;_DistortionSpeed;DistortionSpeed;15;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-1366.346,962.9081;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;139;2901.368,2018.001;Inherit;False;ImpactWave;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-1394.517,1070.382;Inherit;False;77;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;86;-2559.756,421.4631;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;3710.288,2510.567;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;23;-2823.219,1355.964;Inherit;False;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;161;3865.835,2561.547;Inherit;False;ObjectWave;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-2238.405,268.946;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;48;-2326.093,1202.785;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-1220.172,1007.899;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-2354.565,421.0272;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;-1281.087,1247.7;Inherit;False;139;ImpactWave;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;141;-1027.611,1213.247;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;89;-2073.09,372.3629;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;105;-1741.36,1191.217;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;-1100.881,1328.466;Inherit;False;161;ObjectWave;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;110;-833.7714,1010.14;Inherit;False;447.8374;208.142;máscara del agua;2;106;28;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SinOpNode;90;-1936.831,378.5287;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;163;-897.8813,1247.466;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;43;-540.7951,-242.3711;Inherit;False;798;772.4826;Distorsión animada del agua;6;11;6;4;5;1;8;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;109;-1144.05,1205.933;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-2071.434,475.4648;Inherit;False;Property;_DistortionStrength;DistortionStrength;19;0;Create;True;0;0;0;False;0;False;0;0.01;0;0.01;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;8;-400.8588,419.1114;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-487.7948,209.6294;Inherit;False;Property;_DistortionAmount;DistortionAmount;23;0;Create;True;0;0;0;False;0;False;0.05;0.05;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;5;-490.7948,-192.3709;Inherit;True;Property;_Agua;Agua;33;0;Create;True;0;0;0;False;0;False;82b77ae84bd708241b7a49816c40f93d;82b77ae84bd708241b7a49816c40f93d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Vector2Node;11;-456.9538,288.7732;Inherit;False;Property;_MoveDistortionSpeed;MoveDistortionSpeed;13;0;Create;True;0;0;0;False;0;False;0,0;0.02,0.02;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-1787.31,378.6984;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;28;-783.7713,1060.14;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;6;-475.7948,2.629082;Inherit;True;Property;_Texture1;Texture 1;31;0;Create;True;0;0;0;False;0;False;301efde3a1ab4734e858532b281b44fe;301efde3a1ab4734e858532b281b44fe;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;47;783.5708,-24.83518;Inherit;False;1078.521;519.5778;mask + transparencia;6;49;32;50;34;33;107;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-630.9336,1102.282;Inherit;False;WaterSurfaceMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1;-81.79382,-124.3708;Inherit;False;UI-Sprite Effect Layer;0;;1;789bf62641c5cfe4ab7126850acc22b8;18,74,0,204,0,191,0,225,0,242,0,237,0,249,0,186,0,177,0,182,1,229,0,92,0,98,0,234,0,126,0,129,1,130,0,31,0;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-1577.999,197.9143;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;33;795.3737,109.7907;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;107;1013.966,352.6114;Inherit;False;106;WaterSurfaceMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;94;-1337.07,262.327;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-1139.523,262.3064;Inherit;False;DistortedScreenUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;49;1271.549,403.8131;Inherit;False;Property;_WaterTransparency;WaterTransparency;10;0;Create;True;0;0;0;False;0;False;0.3;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;111;1321.461,508.2832;Inherit;False;542.8811;339.0411;captura del fondo;3;104;81;85;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;1321.868,185.1571;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;1371.461,558.2837;Inherit;False;101;DistortedScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;1564.469,240.1428;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;81;1607.565,559.4221;Inherit;False;Global;_GrabScreen0;Grab Screen 0;13;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;34;1732.948,50.85968;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;85;1564.342,731.3248;Inherit;False;Property;_RefractionBlend;RefractionBlend;14;0;Create;True;0;0;0;False;0;False;0.5;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;100;2055.166,454.659;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;84;2033.953,257.1118;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;172;-297.565,1315.892;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.03;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;174;-115.1434,1328.802;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;176;541.2964,1186.19;Inherit;False;ImpactFoamMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;397.246,1182.92;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;179;2102.421,790.8727;Inherit;False;176;ImpactFoamMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;99;2558.935,366.6599;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;164;2108.347,613.8521;Inherit;False;Property;_ImpactFoamColor;ImpactFoamColor;28;0;Create;True;0;0;0;False;0;False;0.7407885,0.7835451,0.8773585,0;0.7407885,0.7835451,0.8773585,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;167;106.1259,1027.517;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;165;-309.3716,1109.676;Inherit;False;Property;_ImpactFoamStrength;ImpactFoamStrength;29;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;177;2488.188,791.2807;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;173;-485.1434,1397.802;Inherit;False;Constant;_Float0;Float 0;28;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;182;-432.4512,1478.744;Inherit;False;Constant;_Float3;Float 3;29;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;171;-475.1832,1310.342;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;168;-619.9545,1313.198;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;169;-988.8702,1545.966;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;170;-2633.677,1612.575;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;-297.2634,1034.25;Inherit;False;152;ObjectInfluence;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;166;-35.82455,1025.367;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2794.169,381.6237;Float;False;True;-1;2;ASEMaterialInspector;0;6;Agua;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.CommentaryNode;103;-2184.944,-562.8098;Inherit;False;647.8616;100;Auxiliary Calculations;0;;1,1,1,1;0;0
WireConnection;120;0;119;0
WireConnection;120;1;113;0
WireConnection;184;0;120;0
WireConnection;184;1;185;0
WireConnection;187;0;123;0
WireConnection;117;0;116;1
WireConnection;117;1;112;0
WireConnection;186;0;184;0
WireConnection;186;1;187;0
WireConnection;118;0;117;0
WireConnection;188;0;186;0
WireConnection;189;0;118;0
WireConnection;128;0;120;0
WireConnection;122;0;120;0
WireConnection;122;1;123;0
WireConnection;127;0;128;0
WireConnection;127;1;126;0
WireConnection;121;0;118;0
WireConnection;121;1;115;0
WireConnection;192;0;190;0
WireConnection;192;1;191;0
WireConnection;133;0;118;0
WireConnection;129;0;127;0
WireConnection;193;0;192;0
WireConnection;146;0;145;0
WireConnection;146;1;147;0
WireConnection;124;0;121;0
WireConnection;124;1;122;0
WireConnection;68;0;69;0
WireConnection;68;1;72;0
WireConnection;13;0;12;0
WireConnection;67;0;66;0
WireConnection;67;1;71;0
WireConnection;132;0;133;0
WireConnection;132;1;131;0
WireConnection;125;0;124;0
WireConnection;194;0;193;0
WireConnection;149;0;146;0
WireConnection;149;1;148;0
WireConnection;22;0;15;0
WireConnection;22;1;40;1
WireConnection;14;0;13;0
WireConnection;14;1;19;0
WireConnection;70;0;67;0
WireConnection;70;1;68;0
WireConnection;130;0;129;0
WireConnection;134;0;132;0
WireConnection;16;0;14;0
WireConnection;16;1;22;0
WireConnection;195;0;194;0
WireConnection;150;0;149;0
WireConnection;135;0;134;0
WireConnection;73;0;70;0
WireConnection;137;0;125;0
WireConnection;137;1;130;0
WireConnection;74;0;73;0
WireConnection;196;0;195;0
WireConnection;17;0;16;0
WireConnection;39;0;36;0
WireConnection;39;1;40;2
WireConnection;138;0;135;0
WireConnection;138;1;137;0
WireConnection;156;0;155;0
WireConnection;151;0;150;0
WireConnection;75;0;74;0
WireConnection;75;1;76;0
WireConnection;37;0;39;0
WireConnection;18;0;17;0
WireConnection;18;1;21;0
WireConnection;157;0;156;0
WireConnection;152;0;151;0
WireConnection;136;0;138;0
WireConnection;136;1;114;0
WireConnection;41;0;37;0
WireConnection;41;1;42;0
WireConnection;27;0;26;0
WireConnection;27;1;18;0
WireConnection;77;0;75;0
WireConnection;158;0;157;0
WireConnection;158;1;152;0
WireConnection;197;0;136;0
WireConnection;197;1;198;0
WireConnection;38;0;27;0
WireConnection;38;1;41;0
WireConnection;139;0;197;0
WireConnection;160;0;158;0
WireConnection;160;1;159;0
WireConnection;23;0;12;0
WireConnection;161;0;160;0
WireConnection;98;0;83;2
WireConnection;98;1;97;0
WireConnection;48;0;23;0
WireConnection;79;0;38;0
WireConnection;79;1;80;0
WireConnection;87;0;86;0
WireConnection;87;1;88;0
WireConnection;141;0;79;0
WireConnection;141;1;140;0
WireConnection;89;0;98;0
WireConnection;89;1;87;0
WireConnection;105;0;48;0
WireConnection;90;0;89;0
WireConnection;163;0;141;0
WireConnection;163;1;162;0
WireConnection;109;0;105;0
WireConnection;92;0;90;0
WireConnection;92;1;91;0
WireConnection;28;0;109;0
WireConnection;28;1;163;0
WireConnection;106;0;28;0
WireConnection;1;37;5;0
WireConnection;1;75;6;0
WireConnection;1;80;4;0
WireConnection;1;183;11;0
WireConnection;1;40;8;0
WireConnection;93;0;83;1
WireConnection;93;1;92;0
WireConnection;33;0;1;0
WireConnection;94;0;93;0
WireConnection;94;1;83;2
WireConnection;101;0;94;0
WireConnection;32;0;33;3
WireConnection;32;1;107;0
WireConnection;50;0;32;0
WireConnection;50;1;49;0
WireConnection;81;0;104;0
WireConnection;34;0;33;0
WireConnection;34;1;33;1
WireConnection;34;2;33;2
WireConnection;34;3;50;0
WireConnection;100;0;50;0
WireConnection;84;0;34;0
WireConnection;84;1;81;0
WireConnection;84;2;85;0
WireConnection;172;0;171;0
WireConnection;172;1;182;0
WireConnection;172;2;173;0
WireConnection;174;0;172;0
WireConnection;176;0;175;0
WireConnection;175;0;167;0
WireConnection;175;1;174;0
WireConnection;99;0;84;0
WireConnection;99;3;100;0
WireConnection;167;0;166;0
WireConnection;177;1;164;0
WireConnection;177;2;179;0
WireConnection;171;0;168;0
WireConnection;168;0;163;0
WireConnection;168;1;169;0
WireConnection;169;0;170;0
WireConnection;170;0;23;0
WireConnection;166;0;153;0
WireConnection;166;1;165;0
WireConnection;0;0;99;0
ASEEND*/
//CHKSM=9E9F7A4C1C39E60FF8EBE52E1F742E9C40BAFAB0