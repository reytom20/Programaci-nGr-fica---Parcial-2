// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PP_Blink"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_Blur("Blur", Range( 0 , 1)) = 0
		_BlurRadius("BlurRadius", Range( 0 , 0.05)) = 0.02
		_Open("Open", Range( 0 , 1)) = 1
		_MaxOpenHeight("MaxOpenHeight", Range( 0.4 , 1)) = 0.7
		_LidCurve("LidCurve", Range( 0 , 1)) = 0.5
		_LidSoftness("LidSoftness", Range( 0.001 , 0.3)) = 0.06
		_LidColor("LidColor", Color) = (0.03,0.022,0.02,1)
		_VignetteSize("VignetteSize", Range( 0 , 1)) = 0.55
		_VignetteSoftness("VignetteSoftness", Range( 0.01 , 1)) = 0.35
		_VignetteAmount("VignetteAmount", Range( 0 , 1)) = 1

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
			
			uniform float _Blur;
			uniform float _BlurRadius;
			uniform float4 _LidColor;
			uniform float _Open;
			uniform float _MaxOpenHeight;
			uniform float _LidCurve;
			uniform float _LidSoftness;
			uniform float _VignetteSize;
			uniform float _VignetteSoftness;
			uniform float _VignetteAmount;


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
				float2 _Centro = float2(0.5,0.5);
				float4 lerpResult14 = lerp( tex2D( _MainTex, texCoord2 ) , tex2D( _MainTex, ( ( ( texCoord2 - _Centro ) * ( 1.0 - ( _Blur * _BlurRadius ) ) ) + _Centro ) ) , 0.5);
				float4 colorDesenfocado15 = lerpResult14;
				float2 texCoord18 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_26_0 = ( ( texCoord18.x - 0.5 ) * 2.0 );
				float temp_output_23_0 = ( 1.0 - _Open );
				float temp_output_32_0 = ( ( _Open * _MaxOpenHeight ) * ( 1.0 - ( ( ( temp_output_26_0 * temp_output_26_0 ) * _LidCurve ) * temp_output_23_0 ) ) );
				float smoothstepResult36 = smoothstep( ( temp_output_32_0 - _LidSoftness ) , temp_output_32_0 , abs( ( texCoord18.y - 0.5 ) ));
				float4 lerpResult39 = lerp( colorDesenfocado15 , _LidColor , smoothstepResult36);
				float4 colorParpados40 = lerpResult39;
				float2 texCoord41 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult46 = (float4(( _ScreenParams.x / _ScreenParams.y ) , 1.0 , 0.0 , 0.0));
				float smoothstepResult53 = smoothstep( _VignetteSize , ( _VignetteSize + _VignetteSoftness ) , length( ( float4( ( texCoord41 - float2( 0.5,0.5 ) ), 0.0 , 0.0 ) * appendResult46 ) ));
				float cierre24 = temp_output_23_0;
				float vignette59 = ( 1.0 - ( ( smoothstepResult53 * _VignetteAmount ) * cierre24 ) );
				

				finalColor = ( colorParpados40 * vignette59 );

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
235;72;822;514;2119.353;637.6682;3.569016;False;False
Node;AmplifyShaderEditor.CommentaryNode;64;-1750,-810;Inherit;False;2774;695;Blink;25;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31;32;33;34;35;36;37;38;39;40;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-1700,-590;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;63;-1750,-1610;Inherit;False;2143;705;Desenfoque;15;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1680.28,-356.1901;Inherit;False;Constant;_Centro05;Centro 0.5;4;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1700,-1560;Inherit;False;Property;_Blur;Blur;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1700,-1490;Inherit;False;Property;_BlurRadius;BlurRadius;1;0;Create;True;0;0;0;False;0;False;0.02;0.02;0;0.05;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1312.997,-466.1349;Inherit;False;Constant;_Escala2;Escala 2;4;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;65;-1750,-70;Inherit;False;2474;745;Vignette;19;41;42;43;44;45;46;47;48;49;50;51;52;53;54;55;56;57;58;59;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;25;-1350,-560;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1700,-1300;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenParams;43;-1700,400;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1150,-560;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;3;-1700,-1150;Inherit;False;Constant;_Centro;Centro;0;0;Create;True;0;0;0;False;0;False;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-1350,-1540;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;7;-1150,-1540;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-950,-560;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;8;-1350,-1250;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;41;-1700,80;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;45;-1350,360;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1350,560;Inherit;False;Constant;_Uno1;Uno 1;7;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;42;-1700,230;Inherit;False;Constant;_Vector0;Vector 0;7;0;Create;True;0;0;0;False;0;False;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;21;-1046.776,-295.07;Inherit;False;Property;_LidCurve;LidCurve;4;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1700,-760;Inherit;False;Property;_Open;Open;2;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-750,-540;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;47;-1350,130;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;23;-1317.312,-638.1655;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1000,-1300;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;46;-1150,400;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1700,-690;Inherit;False;Property;_MaxOpenHeight;MaxOpenHeight;3;0;Create;True;0;0;0;False;0;False;0.7;0.7;0.4;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;1;-1700,-1420;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-950,180;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-950,50;Inherit;False;Property;_VignetteSoftness;VignetteSoftness;8;0;Create;True;0;0;0;False;0;False;0.35;0.35;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-550,-560;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-950,-20;Inherit;False;Property;_VignetteSize;VignetteSize;7;0;Create;True;0;0;0;False;0;False;0.55;0.55;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-800,-1250;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-550,-720;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;49;-750,180;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;-550,-1560;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-550,20;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;30;-350,-560;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-330,-1020;Inherit;False;Constant;_Promedio05;Promedio 0.5;2;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;12;-550,-1300;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;33;-1369.72,-377.815;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-350,330;Inherit;False;Property;_VignetteAmount;VignetteAmount;9;0;Create;True;0;0;0;False;0;False;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;53;-350,150;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-1150,-760;Inherit;False;cierre;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;14;-100,-1400;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-154.2042,-571.3301;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-309.5062,-333.092;Inherit;False;Property;_LidSoftness;LidSoftness;5;0;Create;True;0;0;0;False;0;False;0.06;0.06;0.001;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;122.8739,-581.0203;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;150,-1400;Inherit;False;colorDesenfocado;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.AbsOpNode;34;-1150,-400;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-100,220;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-78.13699,424.6472;Inherit;False;24;cierre;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;100,280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;36;303.2539,-484.2043;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;38;200.9503,-338.9787;Inherit;False;Property;_LidColor;LidColor;6;0;Create;True;0;0;0;False;0;False;0.03,0.022,0.02,1;0.03,0.022,0.02,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;37;250,-720;Inherit;False;15;colorDesenfocado;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;58;300,280;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;39;550,-560;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;500,280;Inherit;False;vignette;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;800,-560;Inherit;False;colorParpados;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;66;1050,-250;Inherit;False;462;285;salida;3;60;61;62;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;1100,-80;Inherit;False;59;vignette;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;1100,-200;Inherit;False;40;colorParpados;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;1350,-150;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1600,-150;Float;False;True;-1;2;ASEMaterialInspector;0;2;PP_Blink;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;25;0;18;1
WireConnection;25;1;19;0
WireConnection;26;0;25;0
WireConnection;26;1;20;0
WireConnection;6;0;4;0
WireConnection;6;1;5;0
WireConnection;7;0;6;0
WireConnection;27;0;26;0
WireConnection;27;1;26;0
WireConnection;8;0;2;0
WireConnection;8;1;3;0
WireConnection;45;0;43;1
WireConnection;45;1;43;2
WireConnection;28;0;27;0
WireConnection;28;1;21;0
WireConnection;47;0;41;0
WireConnection;47;1;42;0
WireConnection;23;0;16;0
WireConnection;9;0;8;0
WireConnection;9;1;7;0
WireConnection;46;0;45;0
WireConnection;46;1;44;0
WireConnection;48;0;47;0
WireConnection;48;1;46;0
WireConnection;29;0;28;0
WireConnection;29;1;23;0
WireConnection;10;0;9;0
WireConnection;10;1;3;0
WireConnection;31;0;16;0
WireConnection;31;1;17;0
WireConnection;49;0;48;0
WireConnection;11;0;1;0
WireConnection;11;1;2;0
WireConnection;52;0;50;0
WireConnection;52;1;51;0
WireConnection;30;0;29;0
WireConnection;12;0;1;0
WireConnection;12;1;10;0
WireConnection;33;0;18;2
WireConnection;33;1;19;0
WireConnection;53;0;49;0
WireConnection;53;1;50;0
WireConnection;53;2;52;0
WireConnection;24;0;23;0
WireConnection;14;0;11;0
WireConnection;14;1;12;0
WireConnection;14;2;13;0
WireConnection;32;0;31;0
WireConnection;32;1;30;0
WireConnection;35;0;32;0
WireConnection;35;1;22;0
WireConnection;15;0;14;0
WireConnection;34;0;33;0
WireConnection;56;0;53;0
WireConnection;56;1;54;0
WireConnection;57;0;56;0
WireConnection;57;1;55;0
WireConnection;36;0;34;0
WireConnection;36;1;35;0
WireConnection;36;2;32;0
WireConnection;58;0;57;0
WireConnection;39;0;37;0
WireConnection;39;1;38;0
WireConnection;39;2;36;0
WireConnection;59;0;58;0
WireConnection;40;0;39;0
WireConnection;62;0;60;0
WireConnection;62;1;61;0
WireConnection;0;0;62;0
ASEEND*/
//CHKSM=F5419ADE39C13D3A0C300A00B9AEBE9AFF450BD2