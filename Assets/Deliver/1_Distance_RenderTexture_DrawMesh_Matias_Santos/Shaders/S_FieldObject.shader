// Upgrade NOTE: upgraded instancing buffer 'Parcial2P1S_FieldObject' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Parcial2/P1/S_FieldObject"
{
	Properties
	{
		_Color("_Color", Color) = (1,1,1,1)
		_FadeColor("_FadeColor", Color) = (0.02,0.03,0.08,1)
		_FadeStart("_FadeStart", Range( 0 , 100)) = 18
		_FadeEnd("_FadeEnd", Range( 0 , 100)) = 40
		_FadeAmount("_FadeAmount", Range( 0 , 1)) = 0.25
		_Metallic("_Metallic", Range( 0 , 1)) = 0
		_Smoothness("_Smoothness", Range( 0 , 1)) = 0.45
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float3 worldPos;
		};

		uniform float4 _FadeColor;
		uniform float _FadeStart;
		uniform float _FadeEnd;
		uniform float _FadeAmount;
		uniform float _Metallic;
		uniform float _Smoothness;

		UNITY_INSTANCING_BUFFER_START(Parcial2P1S_FieldObject)
			UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
#define _Color_arr Parcial2P1S_FieldObject
		UNITY_INSTANCING_BUFFER_END(Parcial2P1S_FieldObject)

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 _Color_Instance = UNITY_ACCESS_INSTANCED_PROP(_Color_arr, _Color);
			float3 ase_worldPos = i.worldPos;
			float smoothstepResult9 = smoothstep( _FadeStart , _FadeEnd , distance( ase_worldPos , _WorldSpaceCameraPos ));
			float niebla14 = ( smoothstepResult9 * _FadeAmount );
			float4 lerpResult11 = lerp( _Color_Instance , _FadeColor , niebla14);
			o.Albedo = lerpResult11.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
307.5;72;944;457.5;410.0908;350.2092;1.3;False;False
Node;AmplifyShaderEditor.CommentaryNode;16;-1750,-150;Inherit;False;1374;435;Niebla> distancia del objeto;9;6;7;8;3;4;9;5;10;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;6;-1700,-100;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;7;-1700,40;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DistanceOpNode;8;-1400,-40;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1400,170;Inherit;False;Property;_FadeEnd;_FadeEnd;3;0;Create;True;0;0;0;False;0;False;40;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1400,100;Inherit;False;Property;_FadeStart;_FadeStart;2;0;Create;True;0;0;0;False;0;False;18;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;9;-1100,0;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1100,160;Inherit;False;Property;_FadeAmount;_FadeAmount;4;0;Create;True;0;0;0;False;0;False;0.25;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-850,40;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;17;-200,-310;Inherit;False;650;545;Color;6;1;2;15;11;12;13;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-600,40;Inherit;False;niebla;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-150,-100;Inherit;False;Property;_FadeColor;_FadeColor;1;0;Create;True;0;0;0;False;0;False;0.02,0.03,0.08,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1;-150,-260;Inherit;False;InstancedProperty;_Color;_Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;15;-150,120;Inherit;False;14;niebla;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;150,100;Inherit;False;Property;_Smoothness;_Smoothness;6;0;Create;True;0;0;0;False;0;False;0.45;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;11;150,-150;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;12;150,30;Inherit;False;Property;_Metallic;_Metallic;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;524.6998,-194.9001;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Parcial2/P1/S_FieldObject;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;9;0;8;0
WireConnection;9;1;3;0
WireConnection;9;2;4;0
WireConnection;10;0;9;0
WireConnection;10;1;5;0
WireConnection;14;0;10;0
WireConnection;11;0;1;0
WireConnection;11;1;2;0
WireConnection;11;2;15;0
WireConnection;0;0;11;0
WireConnection;0;3;12;0
WireConnection;0;4;13;0
ASEEND*/
//CHKSM=AB0FEC14FC24747045A28B8028398D75240E79B7