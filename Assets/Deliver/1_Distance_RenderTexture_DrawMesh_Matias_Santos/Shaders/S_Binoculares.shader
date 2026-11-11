// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "S_Binoculares"
{
	Properties
	{
		_CenterLeft("CenterLeft", Vector) = (-0.12,0,0,0)
		_CenterRight("CenterRight", Vector) = (0.12,0,0,0)
		_Radius("Radius", Range( 0 , 0.5)) = 0.18
		_Fade("Fade", Range( 0 , 0.3)) = 0.04
		_ReticleSize("ReticleSize", Range( 0 , 0.05)) = 0.012
		_BinocularColor("BinocularColor", Color) = (0,0,0,1)
		_ReticleColor("ReticleColor", Color) = (1,1,1,1)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
		};

		uniform float4 _BinocularColor;
		uniform float4 _ReticleColor;
		uniform float _ReticleSize;
		uniform float _Radius;
		uniform float _Fade;
		uniform float3 _CenterLeft;
		uniform float3 _CenterRight;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float mira60 = step( distance( ase_vertex3Pos , float3(0,0,0) ) , _ReticleSize );
			float4 lerpResult64 = lerp( _BinocularColor , _ReticleColor , mira60);
			o.Emission = lerpResult64.rgb;
			float smoothstepResult53 = smoothstep( _Radius , ( _Radius + _Fade ) , min( distance( ase_vertex3Pos , _CenterLeft ) , distance( ase_vertex3Pos , _CenterRight ) ));
			float fueraDeLentes54 = smoothstepResult53;
			o.Alpha = max( fueraDeLentes54 , mira60 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
307.5;72;944;457.5;1597.582;-342.8728;1.3;False;False
Node;AmplifyShaderEditor.CommentaryNode;68;-1550,-280;Inherit;False;1574;605;lentes;11;44;45;46;47;48;49;50;51;52;53;54;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;69;-1550,470;Inherit;False;1124;394;mira;6;55;56;57;58;59;60;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;44;-1500,-230;Inherit;False;Property;_CenterLeft;CenterLeft;0;0;Create;True;0;0;0;False;0;False;-0.12,0,0;-0.12,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;45;-1500,-60;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;46;-1500,120;Inherit;False;Property;_CenterRight;CenterRight;1;0;Create;True;0;0;0;False;0;False;0.12,0,0;0.12,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;56;-1500,680;Inherit;False;Constant;_Centro000;Centro (0,0,0);4;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;50;-900,130;Inherit;False;Property;_Radius;Radius;2;0;Create;True;0;0;0;False;0;False;0.18;0.18;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-900,210;Inherit;False;Property;_Fade;Fade;3;0;Create;True;0;0;0;False;0;False;0.04;0.04;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;47;-1150,-150;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;55;-1500,520;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;48;-1150,60;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;57;-1150,580;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-650,170;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-1179.778,741.6544;Inherit;False;Property;_ReticleSize;ReticleSize;4;0;Create;True;0;0;0;False;0;False;0.012;0.012;0;0.05;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;49;-900,-40;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;53;-450,20;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;59;-900,620;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-200,20;Inherit;False;fueraDeLentes;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;70;200,-200;Inherit;False;532;745;final;7;61;62;63;64;65;66;67;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-650,620;Inherit;False;mira;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;250,320;Inherit;False;54;fueraDeLentes;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;61;250,-150;Inherit;False;Property;_BinocularColor;BinocularColor;5;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;62;250,10;Inherit;False;Property;_ReticleColor;ReticleColor;6;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;63;250,170;Inherit;False;60;mira;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;250,430;Inherit;False;60;mira;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;67;550,360;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;64;550,0;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;850,100;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;S_Binoculares;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;47;0;45;0
WireConnection;47;1;44;0
WireConnection;48;0;45;0
WireConnection;48;1;46;0
WireConnection;57;0;55;0
WireConnection;57;1;56;0
WireConnection;52;0;50;0
WireConnection;52;1;51;0
WireConnection;49;0;47;0
WireConnection;49;1;48;0
WireConnection;53;0;49;0
WireConnection;53;1;50;0
WireConnection;53;2;52;0
WireConnection;59;0;57;0
WireConnection;59;1;58;0
WireConnection;54;0;53;0
WireConnection;60;0;59;0
WireConnection;67;0;65;0
WireConnection;67;1;66;0
WireConnection;64;0;61;0
WireConnection;64;1;62;0
WireConnection;64;2;63;0
WireConnection;0;2;64;0
WireConnection;0;9;67;0
ASEEND*/
//CHKSM=B54F7069A91BA5F4F90652DF632FCF4A10DFCA87