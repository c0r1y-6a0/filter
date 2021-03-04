using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessingBlur : MonoBehaviour
{
    public Material Gaussian;
        RenderTexture rt;
    // Start is called before the first frame update
    void Start()
    {
        rt = new RenderTexture(Screen.width, Screen.height, 0);
        //Gaussian.SetFloatArray("Gaussian_Weight", new float[5]{ 0.227027f, 0.1945946f, 0.1216216f, 0.054054f, 0.016216f});
    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnDestroy()
    {
        rt.Release();
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, rt, Gaussian, 0);
        Graphics.Blit(rt, destination, Gaussian, 1);
    }
}
