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
		_WaterTransparency("WaterTransparency", Float) = 0.3
		_NoiseScale("NoiseScale", Float) = 0
		_NoiseSpeed("NoiseSpeed", Float) = 0.15
		_MoveDistortionSpeed("MoveDistortionSpeed", Vector) = (0,0,0,0)
		_DistortionSpeed("DistortionSpeed", Float) = 0
		_WaveAmplitude("WaveAmplitude", Float) = 0
		_DistortionFrequency("DistortionFrequency", Float) = 0
		_DistortionStrength("DistortionStrength", Float) = 0
		_NoiseAmplitude("NoiseAmplitude", Float) = 0
		_DistortionAmount("DistortionAmount", Range( 0 , 1)) = 0.05
		_Texture1("Texture 1", 2D) = "white" {}
		_Agua("Agua", 2D) = "white" {}

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
			uniform float _WaterTransparency;
			ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
			uniform float _DistortionFrequency;
			uniform float _DistortionSpeed;
			uniform float _DistortionStrength;
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
				float temp_output_50_0 = ( ( break33.a * step( (texCoord12).y , ( ( ( _WaterLevel + ( sin( ( ( (texCoord12).x * _WaveFrequency ) + ( _Time.y * _WaveSpeed.x ) ) ) * _WaveAmplitude ) ) + ( sin( ( _Time.y * _WaveSpeed.y ) ) * 0.02 ) ) + Noise77 ) ) ) * _WaterTransparency );
				float4 appendResult34 = (float4(break33.r , break33.g , break33.b , temp_output_50_0));
				float4 screenPos = IN.ase_texcoord1;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 appendResult94 = (float2(( ( sin( ( ( ase_grabScreenPosNorm.g * _DistortionFrequency ) + ( _Time.y * _DistortionSpeed ) ) ) * _DistortionStrength ) + ase_grabScreenPosNorm.r ) , ase_grabScreenPosNorm.g));
				float4 screenColor81 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,appendResult94);
				float4 lerpResult84 = lerp( appendResult34 , screenColor81 , 0.5);
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
363;73;1101;540;-873.0897;-160.8027;1.390899;False;False
Node;AmplifyShaderEditor.CommentaryNode;78;-2308.21,-483.3082;Inherit;False;1464.543;462.8422;ruido OLAS;12;67;66;71;69;72;68;70;73;74;75;76;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;24;-184.538,632.7358;Inherit;False;253.1127;147.6426;uv.x;1;13;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-832.3876,751.5959;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;71;-2220.215,-308.1055;Inherit;False;Property;_NoiseScale;NoiseScale;11;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;69;-2228.077,-209.8391;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-2258.21,-136.4671;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;12;0;Create;True;0;0;0;False;0;False;0.15;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;66;-2257.979,-433.3083;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;15;-155.1726,933.8337;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;13;-134.538,687.8359;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;45;139.293,568.9999;Inherit;False;652.7225;325.7186;Movimiento horizontal OLAS;6;21;18;17;16;22;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-1972.579,-263.5585;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;40;-82.32561,1018.724;Inherit;False;Property;_WaveSpeed;WaveSpeed;8;0;Create;True;0;0;0;False;0;False;0,0;2,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-1956.856,-414.2349;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-172.122,818.2032;Inherit;False;Property;_WaveFrequency;WaveFrequency;7;0;Create;True;0;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;166.0065,787.7936;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;149.7597,618.9999;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;-1751.145,-348.7226;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;73;-1621.434,-353.9628;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;369.793,712.136;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;46;159.9814,1181.722;Inherit;False;540.0364;292.6381;oscilación vertical OLAS;4;39;42;37;41;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;36;-16.73104,1368.292;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;86;1334.471,1087.997;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;74;-1398.692,-342.1702;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;1316.223,1169.153;Inherit;False;Property;_DistortionSpeed;DistortionSpeed;14;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;83;1379.28,780.8521;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;97;1376.569,975.6819;Inherit;False;Property;_DistortionFrequency;DistortionFrequency;16;0;Create;True;0;0;0;False;0;False;0;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;443.1553,820.2283;Inherit;False;Property;_WaveAmplitude;WaveAmplitude;15;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;209.9814,1231.722;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;17;520.2319,713.8076;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1462.896,-224.3123;Inherit;False;Property;_NoiseAmplitude;NoiseAmplitude;18;0;Create;True;0;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-1217.881,-329.8895;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;669.5488,716.7717;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;37;405.1611,1259.954;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;351.8502,1358.36;Inherit;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;0;False;0;False;0.02;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;1658.09,935.4799;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;645.6263,937.8221;Inherit;False;Property;_WaterLevel;WaterLevel;9;0;Create;True;0;0;0;False;0;False;0;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;1539.663,1087.561;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;842.8029,831.3994;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;43;-540.7951,-242.3711;Inherit;False;798;772.4826;Distorsión animada del agua;6;11;6;4;5;1;8;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-1067.664,-325.2015;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;89;1832.322,1087.021;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;25;-209.9072,1166.58;Inherit;False;256.1723;155.2915;uv.y;1;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;538.0176,1296.304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;857.6689,1254.314;Inherit;False;77;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-487.7948,209.6294;Inherit;False;Property;_DistortionAmount;DistortionAmount;19;0;Create;True;0;0;0;False;0;False;0.05;0.05;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;11;-456.9538,288.7732;Inherit;False;Property;_MoveDistortionSpeed;MoveDistortionSpeed;13;0;Create;True;0;0;0;False;0;False;0,0;0.02,0.02;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;38;913.5207,1102.916;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;5;-490.7948,-192.3709;Inherit;True;Property;_Agua;Agua;21;0;Create;True;0;0;0;False;0;False;82b77ae84bd708241b7a49816c40f93d;82b77ae84bd708241b7a49816c40f93d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleTimeNode;8;-400.8588,419.1114;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;90;1965.018,1089.622;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;23;-159.9072,1216.58;Inherit;False;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;1878.253,1198.46;Inherit;False;Property;_DistortionStrength;DistortionStrength;17;0;Create;True;0;0;0;False;0;False;0;0.005;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;6;-475.7948,2.629082;Inherit;True;Property;_Texture1;Texture 1;20;0;Create;True;0;0;0;False;0;False;301efde3a1ab4734e858532b281b44fe;301efde3a1ab4734e858532b281b44fe;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;47;783.5708,-24.83518;Inherit;False;1078.521;519.5778;transparencia;5;49;32;50;34;33;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;1;-81.79382,-124.3708;Inherit;False;UI-Sprite Effect Layer;0;;1;789bf62641c5cfe4ab7126850acc22b8;18,74,0,204,0,191,0,225,0,242,0,237,0,249,0,186,0,177,0,182,1,229,0,92,0,98,0,234,0,126,0,129,1,130,0,31,0;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.WireNode;48;229.5648,1104.393;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;1046.586,1110.808;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;2125.234,1088.009;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;33;795.3737,109.7907;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.StepOpNode;28;1168.754,935.8663;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;95;2401.471,891.2754;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;2334.549,969.6077;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;1321.868,185.1571;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;1378.804,414.3016;Inherit;False;Property;_WaterTransparency;WaterTransparency;10;0;Create;True;0;0;0;False;0;False;0.3;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;94;2607.563,939.555;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;96;1793.574,876.9291;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;1584.235,246.0724;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;34;1711.206,25.16482;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;81;1860.813,718.6293;Inherit;False;Global;_GrabScreen0;Grab Screen 0;13;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;85;2166.462,778.4424;Inherit;False;Constant;_Float2;Float 2;13;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;84;2256.346,375.1195;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;100;2341.131,597.6548;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;99;2429.552,390.6599;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2582.111,271.7382;Float;False;True;-1;2;ASEMaterialInspector;0;6;Agua;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;13;0;12;0
WireConnection;68;0;69;0
WireConnection;68;1;72;0
WireConnection;67;0;66;0
WireConnection;67;1;71;0
WireConnection;22;0;15;0
WireConnection;22;1;40;1
WireConnection;14;0;13;0
WireConnection;14;1;19;0
WireConnection;70;0;67;0
WireConnection;70;1;68;0
WireConnection;73;0;70;0
WireConnection;16;0;14;0
WireConnection;16;1;22;0
WireConnection;74;0;73;0
WireConnection;39;0;36;0
WireConnection;39;1;40;2
WireConnection;17;0;16;0
WireConnection;75;0;74;0
WireConnection;75;1;76;0
WireConnection;18;0;17;0
WireConnection;18;1;21;0
WireConnection;37;0;39;0
WireConnection;98;0;83;2
WireConnection;98;1;97;0
WireConnection;87;0;86;0
WireConnection;87;1;88;0
WireConnection;27;0;26;0
WireConnection;27;1;18;0
WireConnection;77;0;75;0
WireConnection;89;0;98;0
WireConnection;89;1;87;0
WireConnection;41;0;37;0
WireConnection;41;1;42;0
WireConnection;38;0;27;0
WireConnection;38;1;41;0
WireConnection;90;0;89;0
WireConnection;23;0;12;0
WireConnection;1;37;5;0
WireConnection;1;75;6;0
WireConnection;1;80;4;0
WireConnection;1;183;11;0
WireConnection;1;40;8;0
WireConnection;48;0;23;0
WireConnection;79;0;38;0
WireConnection;79;1;80;0
WireConnection;92;0;90;0
WireConnection;92;1;91;0
WireConnection;33;0;1;0
WireConnection;28;0;48;0
WireConnection;28;1;79;0
WireConnection;95;0;83;2
WireConnection;93;0;92;0
WireConnection;93;1;83;1
WireConnection;32;0;33;3
WireConnection;32;1;28;0
WireConnection;94;0;93;0
WireConnection;94;1;95;0
WireConnection;96;0;94;0
WireConnection;50;0;32;0
WireConnection;50;1;49;0
WireConnection;34;0;33;0
WireConnection;34;1;33;1
WireConnection;34;2;33;2
WireConnection;34;3;50;0
WireConnection;81;0;96;0
WireConnection;84;0;34;0
WireConnection;84;1;81;0
WireConnection;84;2;85;0
WireConnection;100;0;50;0
WireConnection;99;0;84;0
WireConnection;99;3;100;0
WireConnection;0;0;99;0
ASEEND*/
//CHKSM=3E1C7FE23E47C2154FC0B8B89C08C212B1EC7320