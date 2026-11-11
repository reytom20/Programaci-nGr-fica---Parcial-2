// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Parcial2/P6/UI_Flow"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		_FlowRamp("Flow Ramp", 2D) = "white" {}
		_FlowMap("Flow Map", 2D) = "white" {}
		_FlowTint("Flow Tint", Color) = (1,0.75,0.35,1)
		_FlowSpeed("Flow Speed", Range( 0 , 3)) = 0.6
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
		
		Stencil
		{
			Ref [_Stencil]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
			CompFront [_StencilComp]
			PassFront [_StencilOp]
			FailFront Keep
			ZFailFront Keep
			CompBack Always
			PassBack Keep
			FailBack Keep
			ZFailBack Keep
		}


		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		
		Pass
		{
			Name "Default"
		CGPROGRAM
			
			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_CLIP_RECT
			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_COLOR

			
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
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform fixed4 _TextureSampleAdd;
			uniform float4 _ClipRect;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _FlowRamp;
			uniform sampler2D _FlowMap;
			uniform float4 _FlowMap_ST;
			uniform float _FlowSpeed;
			uniform float4 _FlowTint;

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID( IN );
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				OUT.worldPosition = IN.vertex;
				
				
				OUT.worldPosition.xyz +=  float3( 0, 0, 0 ) ;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = IN.texcoord;
				
				OUT.color = IN.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 temp_output_192_0_g1 = tex2D( _MainTex, uv_MainTex );
				float2 uv_FlowMap = IN.texcoord.xy * _FlowMap_ST.xy + _FlowMap_ST.zw;
				float4 tex2DNode14_g1 = tex2D( _FlowMap, uv_FlowMap );
				float2 appendResult20_g1 = (float2(tex2DNode14_g1.r , tex2DNode14_g1.g));
				float mulTime3 = _Time.y * _FlowSpeed;
				float TimeVar197_g1 = mulTime3;
				float2 temp_cast_0 = (TimeVar197_g1).xx;
				float2 temp_output_18_0_g1 = ( appendResult20_g1 - temp_cast_0 );
				float4 tex2DNode72_g1 = tex2D( _FlowRamp, temp_output_18_0_g1 );
				float4 Flow9 = ( temp_output_192_0_g1 + ( ( tex2DNode72_g1 * _FlowTint ) * (temp_output_192_0_g1).a ) );
				
				half4 color = ( Flow9 * IN.color );
				
				#ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif
				
				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
255;72;784;457.5;687.5073;314.7715;1.62326;False;False
Node;AmplifyShaderEditor.CommentaryNode;13;-1750,-350;Inherit;False;350;1145;Propiedades;5;1;5;6;7;8;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;1;-1700,-300;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;14;-1200,-350;Inherit;False;370;280;Sprite base;1;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;15;-1200,610;Inherit;False;248;160;Tiempo x velocidad;1;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1700,680;Inherit;False;Property;_FlowSpeed;Flow Speed;10;0;Create;True;0;0;0;False;0;False;0.6;0.6;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;3;-1150,660;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;6;-1700,180;Inherit;True;Property;_FlowMap;Flow Map;8;0;Create;True;0;0;0;False;0;False;f270691a5045edf478a065bf5c36022b;f270691a5045edf478a065bf5c36022b;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;2;-1150,-300;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;7;-1700,430;Inherit;False;Property;_FlowTint;Flow Tint;9;0;Create;True;0;0;0;False;0;False;1,0.75,0.35,1;1,0.75,0.35,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;16;-700,-50;Inherit;False;674;252;Flow;2;4;9;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;5;-1700,-80;Inherit;True;Property;_FlowRamp;Flow Ramp;7;0;Create;True;0;0;0;False;0;False;50e92d7619e6abd4a8812737aff2eac5;50e92d7619e6abd4a8812737aff2eac5;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;4;-650,0;Inherit;False;UI-Sprite Effect Layer;0;;1;789bf62641c5cfe4ab7126850acc22b8;18,74,1,204,1,191,1,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,0,98,0,234,0,126,0,129,1,130,0,31,2;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;10;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;10;False;30;FLOAT;10;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.CommentaryNode;17;100,-50;Inherit;False;562;392;COLOR;3;10;11;12;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-250,0;Inherit;False;Flow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;11;150,140;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;10;150,0;Inherit;False;9;Flow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;500,50;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;800,0;Float;False;True;-1;2;ASEMaterialInspector;0;4;Parcial2/P6/UI_Flow;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-9;False;False;False;False;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;3;0;8;0
WireConnection;2;0;1;0
WireConnection;4;192;2;0
WireConnection;4;39;7;0
WireConnection;4;37;5;0
WireConnection;4;33;6;0
WireConnection;4;40;3;0
WireConnection;9;0;4;0
WireConnection;12;0;10;0
WireConnection;12;1;11;0
WireConnection;0;0;12;0
ASEEND*/
//CHKSM=A264D491458384BA613C5D869D3AAE0B265B1570