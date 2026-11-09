// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SH_StencilReader"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		ZWrite Off
		ZTest Always
		Stencil
		{
			Ref 5
			Comp Equal
			Pass Keep
			Fail Keep
			ZFail Keep
		}
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float3 worldPos;
		};

		uniform float ScannerRadius;
		uniform float3 ScannerPosition;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color1 = IsGammaSpace() ? float4(0.9245283,0.1003026,0.1003026,0) : float4(0.8368256,0.01006985,0.01006985,0);
			o.Emission = color1.rgb;
			o.Alpha = 1;
			float3 ase_worldPos = i.worldPos;
			clip( ( 1.0 - step( ScannerRadius , distance( ase_worldPos , ScannerPosition ) ) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
363;73;1101;540;1225.628;253.7779;1.739121;False;False
Node;AmplifyShaderEditor.CommentaryNode;9;-744.2242,135.543;Inherit;False;846.9886;412.5372;devuelve 0 si el enemigo está dentro de la esfera, y 1 si está fuera de la esfera, por eso aplicamos one minus;7;8;6;5;4;3;2;13;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;3;-695.702,398.8962;Inherit;False;Global;ScannerPosition;ScannerPosition;1;0;Create;True;0;0;0;False;0;False;0,0,0;0,1,-4.92;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;2;-707.8764,237.9408;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DistanceOpNode;4;-401.2242,295.8538;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-451.7958,185.543;Inherit;False;Global;ScannerRadius;ScannerRadius;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;6;-221.6964,299.9444;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;8;-79.16998,283.834;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;25.30223,-53.26088;Inherit;False;Constant;_Color0;Color 0;0;0;Create;True;0;0;0;False;0;False;0.9245283,0.1003026,0.1003026,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;289.1464,443.6096;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;362.0974,-19.5;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;SH_StencilReader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;2;False;-1;7;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;All;14;all;True;True;True;True;0;False;-1;True;5;False;-1;255;False;-1;255;False;-1;5;False;-1;1;False;-1;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;13;-726.5722,186.2017;Inherit;False;227.6523;194.7394;posición del enemigo;0;;1,1,1,1;0;0
WireConnection;4;0;2;0
WireConnection;4;1;3;0
WireConnection;6;0;5;0
WireConnection;6;1;4;0
WireConnection;8;0;6;0
WireConnection;0;2;1;0
WireConnection;0;10;8;0
ASEEND*/
//CHKSM=01C0E4C3CD8CE425A2BCD67C804AF76EFC4AB99B