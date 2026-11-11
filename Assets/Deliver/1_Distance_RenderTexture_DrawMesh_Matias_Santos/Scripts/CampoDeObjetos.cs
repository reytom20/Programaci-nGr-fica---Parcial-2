using System.Collections.Generic;
using UnityEngine;

// Dibuja una pared de objetos 3D con Graphics.DrawtaMeshInsnced-no son GameObjects,
// solo datos (posicion, tamanio, color, giro). 
// Uno solo es unico y el objetivo.
public class CampoDeObjetos : MonoBehaviour
{
    [SerializeField] Mesh[] meshes;
    [SerializeField] Material material;           // S_FieldObject con GPU Instancing
    [SerializeField] Color[] colores;

    [Header("Grilla")]
    [SerializeField] int columnas = 42;
    [SerializeField] int filas = 24;
    [SerializeField] float ancho = 67f;
    [SerializeField] float alto = 38f;

    [Header("Objetos")]
    [SerializeField] float tamanioMin = 0.6f;
    [SerializeField] float tamanioMax = 2.2f;
    [SerializeField] float giroMin = 20f;
    [SerializeField] float giroMax = 120f;

    struct Objeto
    {
        public int mesh, color;
        public Vector3 posicion, eje;
        public float escala, radio, velocidad, angulo;
    }

    Objeto[] objetos;
    List<int>[] porMesh;                  // indices de objetos agrupados por mesh (un DrawMeshInstanced por mesh)
    Matrix4x4[][] matrices;
    MaterialPropertyBlock[] bloques;      // colores de cada grupo

    public int Objetivo { get; private set; }
    public Mesh MeshObjetivo => meshes[objetos[Objetivo].mesh];
    public Color ColorObjetivo => colores[objetos[Objetivo].color];

    public void Generar()
    {
        int total = columnas * filas;
        objetos = new Objeto[total];

        // El objetivo es la unica combinacion de mesh + color que no se repite.
        Objetivo = Random.Range(0, total);
        int meshObjetivo = Random.Range(0, meshes.Length);
        int colorObjetivo = Random.Range(0, colores.Length);

        float celdaX = ancho / columnas;
        float celdaY = alto / filas;

        for (int i = 0; i < total; i++)
        {
            int m = meshObjetivo, c = colorObjetivo;
            if (i != Objetivo)
            {
                do { m = Random.Range(0, meshes.Length); c = Random.Range(0, colores.Length); }
                while (m == meshObjetivo && c == colorObjetivo);
            }

            // Una celda por objeto, con un poco de desorden adentro de la celda.
            float x = -ancho / 2f + (i % columnas + Random.Range(0.2f, 0.8f)) * celdaX;
            float y = -alto / 2f + (i / columnas + Random.Range(0.2f, 0.8f)) * celdaY;

            Vector3 lado = meshes[m].bounds.size;
            float tamanio = Random.Range(tamanioMin, tamanioMax);

            objetos[i] = new Objeto
            {
                mesh = m,
                color = c,
                posicion = transform.position + new Vector3(x, y, Random.Range(-0.5f, 0.5f)),
                eje = Random.onUnitSphere,
                escala = tamanio / Mathf.Max(lado.x, lado.y, lado.z),
                radio = tamanio * 0.5f,
                velocidad = Random.Range(giroMin, giroMax),
                angulo = Random.Range(0f, 360f)
            };
        }

        ArmarGrupos();
    }

    // Agrupa por mesh y carga el color de cada instancia en un MaterialPropertyBlock.
    void ArmarGrupos()
    {
        porMesh = new List<int>[meshes.Length];
        matrices = new Matrix4x4[meshes.Length][];
        bloques = new MaterialPropertyBlock[meshes.Length];

        for (int m = 0; m < meshes.Length; m++) porMesh[m] = new List<int>();
        for (int i = 0; i < objetos.Length; i++) porMesh[objetos[i].mesh].Add(i);

        for (int m = 0; m < meshes.Length; m++)
        {
            matrices[m] = new Matrix4x4[porMesh[m].Count];
            Vector4[] cols = new Vector4[porMesh[m].Count];
            for (int j = 0; j < cols.Length; j++)
                cols[j] = colores[objetos[porMesh[m][j]].color].linear;   // el proyecto esta en Linear

            bloques[m] = new MaterialPropertyBlock();
            if (cols.Length > 0) bloques[m].SetVectorArray("_Color", cols);
        }
    }

    void Update()
    {
        if (objetos == null) return;

        for (int m = 0; m < meshes.Length; m++)
        {
            for (int j = 0; j < porMesh[m].Count; j++)
            {
                int i = porMesh[m][j];
                objetos[i].angulo += objetos[i].velocidad * Time.deltaTime;
                matrices[m][j] = Matrix4x4.TRS(objetos[i].posicion,
                    Quaternion.AngleAxis(objetos[i].angulo, objetos[i].eje),
                    Vector3.one * objetos[i].escala);
            }
            if (porMesh[m].Count > 0)
                Graphics.DrawMeshInstanced(meshes[m], 0, material, matrices[m], porMesh[m].Count, bloques[m]);
        }
    }

    // Devuelve el objeto mas cercano que toca el rayo (sin colliders), o -1.
    public int ObjetoEn(Ray rayo)
    {
        int encontrado = -1;
        float masCerca = float.MaxValue;

        for (int i = 0; i < objetos.Length; i++)
        {
            Vector3 aObjeto = objetos[i].posicion - rayo.origin;
            float t = Vector3.Dot(aObjeto, rayo.direction);
            float distanciaAlRayo = (aObjeto - rayo.direction * t).magnitude;

            if (t > 0f && distanciaAlRayo < objetos[i].radio && t < masCerca)
            {
                masCerca = t;
                encontrado = i;
            }
        }
        return encontrado;
    }
}
