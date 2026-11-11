// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PP_NightCam"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_Barrel("Barrel", Range( 0 , 0.5)) = 0.3
		_Brightness("Brightness", Range( 0 , 8)) = 3.6
		_Contrast("Contrast", Range( 0.5 , 2.5)) = 1.2
		_GrainSpeed("GrainSpeed", Vector) = (24,0,0,0)
		_GrainScale("GrainScale", Range( 50 , 1000)) = 202
		_GrainAmount("GrainAmount", Range( 0 , 1)) = 0.1
		_ScanlineCount("ScanlineCount", Range( 50 , 1080)) = 69
		_ScanlineIntensity("ScanlineIntensity", Range( 0 , 1)) = 0.25
		_VignetteSize("VignetteSize", Range( 0 , 1)) = 0.5
		_VignetteSoftness("VignetteSoftness", Range( 0.01 , 1.5)) = 1
		_TintColor("TintColor", Color) = (0.25,1,0.35,1)
		_Amount("Amount", Range( 0 , 1)) = 0

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
			
			uniform float _Barrel;
			uniform float _Brightness;
			uniform float _Contrast;
			uniform float2 _GrainSpeed;
			uniform float _GrainScale;
			uniform float _GrainAmount;
			uniform float _ScanlineCount;
			uniform float _ScanlineIntensity;
			uniform float _VignetteSize;
			uniform float _VignetteSoftness;
			uniform float4 _TintColor;
			uniform float _Amount;
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
				float2 texCoord1 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float2 _Centro = float2(0.5,0.5);
				float2 temp_output_4_0 = ( texCoord1 - _Centro );
				float dotResult5 = dot( temp_output_4_0 , temp_output_4_0 );
				float2 uvBarril11 = ( ( temp_output_4_0 * ( 1.0 + ( dotResult5 * _Barrel ) ) ) + _Centro );
				float4 tex2DNode14 = tex2D( _MainTex, uvBarril11 );
				float4 pantalla15 = tex2DNode14;
				float3 desaturateInitialColor17 = tex2DNode14.rgb;
				float desaturateDot17 = dot( desaturateInitialColor17, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar17 = lerp( desaturateInitialColor17, desaturateDot17.xxx, 1.0 );
				float3 temp_cast_1 = (0.5).xxx;
				float3 luma25 = ( ( ( ( desaturateVar17 * _Brightness ) - temp_cast_1 ) * _Contrast ) + 0.5 );
				float2 texCoord26 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner29 = ( _Time.y * _GrainSpeed + texCoord26);
				float simplePerlin2D31 = snoise( panner29*_GrainScale );
				simplePerlin2D31 = simplePerlin2D31*0.5 + 0.5;
				float grano36 = ( ( simplePerlin2D31 - 0.5 ) * _GrainAmount );
				float2 texCoord37 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float lineas49 = ( 1.0 + ( ( sin( ( ( texCoord37.y * _ScanlineCount ) * UNITY_PI ) ) * 0.5 ) * _ScanlineIntensity ) );
				float2 texCoord50 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult55 = (float4(( _ScreenParams.x / _ScreenParams.y ) , 1.0 , 0.0 , 0.0));
				float smoothstepResult62 = smoothstep( _VignetteSize , ( _VignetteSize + _VignetteSoftness ) , length( ( float4( ( texCoord50 - float2( 0.5,0.5 ) ), 0.0 , 0.0 ) * appendResult55 ) ));
				float vignette64 = ( 1.0 - smoothstepResult62 );
				float4 lerpResult76 = lerp( pantalla15 , ( float4( ( ( ( luma25 + grano36 ) * lineas49 ) * vignette64 ) , 0.0 ) * _TintColor ) , _Amount);
				

				finalColor = lerpResult76;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
235;72;822;514;-350.8739;631.5646;2.122963;False;False
Node;AmplifyShaderEditor.CommentaryNode;77;-1750,-1370;Inherit;False;1874;465;Angular;11;1;2;3;4;5;6;7;8;9;10;11;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-1700,-1320;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;2;-1700,-1170;Inherit;False;Constant;_Centro;Centro;0;0;Create;True;0;0;0;False;0;False;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-1350,-1300;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1700,-1060;Inherit;False;Property;_Barrel;Barrel;0;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;5;-1150,-1200;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-950,-1150;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-950,-1020;Inherit;False;Constant;_Uno1;Uno 1;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-750,-1130;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-550,-1250;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-350,-1230;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;78;-1750,-850;Inherit;False;2074;495;Brillo/contraste;14;12;13;14;15;16;17;18;19;20;21;22;23;24;25;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-100,-1230;Inherit;False;uvBarril;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;80;-1751.879,225.575;Inherit;False;1874;425;Scanlines;13;37;38;39;40;41;42;43;44;45;46;47;48;49;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;12;-1700,-740;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;13;-1700,-620;Inherit;False;11;uvBarril;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;81;-1750,670;Inherit;False;2054;705;Vignette;15;50;51;52;53;54;55;56;57;58;59;60;61;62;63;64;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1350,-500;Inherit;False;Constant;_Gristotal1;Gris total 1;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;79;-1750,-280;Inherit;False;1674;430;Granulado;11;26;27;28;29;30;31;32;33;34;35;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;37;-1701.879,275.575;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;-1701.879,425.575;Inherit;False;Property;_ScanlineCount;ScanlineCount;6;0;Create;True;0;0;0;False;0;False;69;69;50;1080;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-1350,-740;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;28;-1700,40;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1000,-500;Inherit;False;Property;_Brightness;Brightness;1;0;Create;True;0;0;0;False;0;False;3.6;3.6;0;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1351.879,305.575;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;17;-1000,-650;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;27;-1700,-80;Inherit;False;Property;_GrainSpeed;GrainSpeed;3;0;Create;True;0;0;0;False;0;False;24,0;24,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PiNode;40;-1351.879,445.575;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-1700,-230;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenParams;52;-1700,1090;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;50;-1700,820;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;-700,-470;Inherit;False;Constant;_Pivote05;Pivote 0.5;2;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;29;-1350,-180;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-750,-630;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1350,-30;Inherit;False;Property;_GrainScale;GrainScale;4;0;Create;True;0;0;0;False;0;False;202;202;50;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;53;-1350,1110;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1151.879,345.575;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;51;-1700,970;Inherit;False;Constant;_Vector0;Vector 0;8;0;Create;True;0;0;0;False;0;False;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;54;-1350,1260;Inherit;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;31;-1050,-180;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;55;-1150,1150;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;56;-1350,870;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;21;-550,-630;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;42;-951.8788,345.575;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-550,-500;Inherit;False;Property;_Contrast;Contrast;2;0;Create;True;0;0;0;False;0;False;1.2;1.2;0.5;2.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1050,-30;Inherit;False;Constant;_Centrar05;Centrar 0.5;5;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-951.8788,455.575;Inherit;False;Constant;_Mitad05;Mitad 0.5;7;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-950,790;Inherit;False;Property;_VignetteSoftness;VignetteSoftness;9;0;Create;True;0;0;0;False;0;False;1;1;0.01;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-751.8788,365.575;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-800,-30;Inherit;False;Property;_GrainAmount;GrainAmount;5;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-751.8788,475.575;Inherit;False;Property;_ScanlineIntensity;ScanlineIntensity;7;0;Create;True;0;0;0;False;0;False;0.25;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;33;-800,-160;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-950,920;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-350,-630;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-950,720;Inherit;False;Property;_VignetteSize;VignetteSize;8;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-150,-610;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-551.8788,385.575;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;58;-750,920;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-550,-140;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-351.8788,535.575;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-550,760;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;82;550,-370;Inherit;False;1332;557;conectar todo (luma + grano) x lineas x vignette/tenido de verde/Amount mezcla con la imagen normal;12;65;66;67;68;69;70;71;72;73;74;75;76;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SmoothstepOpNode;62;-350,890;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-351.8788,405.575;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;100,-610;Inherit;False;luma;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-300,-140;Inherit;False;grano;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-101.8788,405.575;Inherit;False;lineas;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;63;-150,890;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;600,-320;Inherit;False;25;luma;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;600,-200;Inherit;False;36;grano;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;80,890;Inherit;False;vignette;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;850,-270;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;850,-140;Inherit;False;49;lineas;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;1050,-80;Inherit;False;64;vignette;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;1050,-220;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;72;1250,-20;Inherit;False;Property;_TintColor;TintColor;10;0;Create;True;0;0;0;False;0;False;0.25,1,0.35,1;0.25,1,0.35,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-1000,-800;Inherit;False;pantalla;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;1250,-170;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;75;1450,60;Inherit;False;Property;_Amount;Amount;11;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;1450,-120;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;1450,-320;Inherit;False;15;pantalla;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;76;1700,-220;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1950,-220;Float;False;True;-1;2;ASEMaterialInspector;0;2;PP_NightCam;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;4;0;1;0
WireConnection;4;1;2;0
WireConnection;5;0;4;0
WireConnection;5;1;4;0
WireConnection;6;0;5;0
WireConnection;6;1;3;0
WireConnection;8;0;7;0
WireConnection;8;1;6;0
WireConnection;9;0;4;0
WireConnection;9;1;8;0
WireConnection;10;0;9;0
WireConnection;10;1;2;0
WireConnection;11;0;10;0
WireConnection;14;0;12;0
WireConnection;14;1;13;0
WireConnection;39;0;37;2
WireConnection;39;1;38;0
WireConnection;17;0;14;0
WireConnection;17;1;16;0
WireConnection;29;0;26;0
WireConnection;29;2;27;0
WireConnection;29;1;28;0
WireConnection;19;0;17;0
WireConnection;19;1;18;0
WireConnection;53;0;52;1
WireConnection;53;1;52;2
WireConnection;41;0;39;0
WireConnection;41;1;40;0
WireConnection;31;0;29;0
WireConnection;31;1;30;0
WireConnection;55;0;53;0
WireConnection;55;1;54;0
WireConnection;56;0;50;0
WireConnection;56;1;51;0
WireConnection;21;0;19;0
WireConnection;21;1;20;0
WireConnection;42;0;41;0
WireConnection;44;0;42;0
WireConnection;44;1;43;0
WireConnection;33;0;31;0
WireConnection;33;1;32;0
WireConnection;57;0;56;0
WireConnection;57;1;55;0
WireConnection;23;0;21;0
WireConnection;23;1;22;0
WireConnection;24;0;23;0
WireConnection;24;1;20;0
WireConnection;46;0;44;0
WireConnection;46;1;45;0
WireConnection;58;0;57;0
WireConnection;35;0;33;0
WireConnection;35;1;34;0
WireConnection;61;0;59;0
WireConnection;61;1;60;0
WireConnection;62;0;58;0
WireConnection;62;1;59;0
WireConnection;62;2;61;0
WireConnection;48;0;47;0
WireConnection;48;1;46;0
WireConnection;25;0;24;0
WireConnection;36;0;35;0
WireConnection;49;0;48;0
WireConnection;63;0;62;0
WireConnection;64;0;63;0
WireConnection;67;0;65;0
WireConnection;67;1;66;0
WireConnection;69;0;67;0
WireConnection;69;1;68;0
WireConnection;15;0;14;0
WireConnection;71;0;69;0
WireConnection;71;1;70;0
WireConnection;73;0;71;0
WireConnection;73;1;72;0
WireConnection;76;0;74;0
WireConnection;76;1;73;0
WireConnection;76;2;75;0
WireConnection;0;0;76;0
ASEEND*/
//CHKSM=2325119068D89FF64F64527E70DF316D4CB4D50F