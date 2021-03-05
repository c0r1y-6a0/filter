using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum E_FILTERMODE
{
    Gaussian = 0,
    Bilateral,
}

public class PostProcessingBlur : MonoBehaviour
{
    public E_FILTERMODE Mode;
    public int SampleCount;
    public float GaussianDelta;

    [Header("Bilateral")]
    public float Sharpness;

    RenderTexture rt;
    Material Mat;
    // Start is called before the first frame update
    void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.DepthNormals;

        rt = new RenderTexture(Screen.width, Screen.height, 0);
        //Gaussian.SetFloatArray("Gaussian_Weight", new float[5]{ 0.227027f, 0.1945946f, 0.1216216f, 0.054054f, 0.016216f});
        switch (Mode)
        {
            case E_FILTERMODE.Gaussian:
                CreateNewGaussianMat();
                break;
            case E_FILTERMODE.Bilateral:
                CreateNewBilateralMat();
                break;
        }
    }

    void CreateNewBilateralMat()
    {
        Mat = new Material(Shader.Find("Hidden/Bilateral"));
        UpdateBilateralMat();
    }

    void UpdateBilateralMat()
    {
        float[] ga = GetGaussianArray(SampleCount, GaussianDelta);
        Mat.SetFloatArray("Gaussian_Weight", ga);
        Mat.SetInt("_Sample", SampleCount);

        m_prevGaussianDelta = GaussianDelta;
        m_prevSampleCount = SampleCount;
    }

    /*
     * exp(-(x*x) / 2)
     */
    float GaussianPDF(float x, float delta)
    {
        return Mathf.Exp(-(x * x) / (2 * delta * delta));
    }

    int GetRange(float delta)
    {
        int i = 1;
        while (GaussianPDF(i, delta) > 0.01)
            i *= 2;
        return i;
    }

    const int SUM_SECTION_COUNT = 100;
    float CDF_Sum(float begin, float end, float delta)
    {
        float sectionLength = (end - begin) / SUM_SECTION_COUNT;
        float size = 0;
        for (int i = 0; i < SUM_SECTION_COUNT; i++)
        {
            float x = begin + (i + 0.5f) * sectionLength;
            float gx = GaussianPDF(x, delta);
            float sectionSize = gx * sectionLength;
            size += sectionSize;
        }
        return size;
    }

    float[] GetGaussianArray(int count, float delta)
    {
        int totalCount = 2 * count + 1;
        float[] weights = new float[totalCount];
        float totalWeight = 0;

        int range = GetRange(delta);

        float sectionSize = 2 * range / (float)totalCount;
        for (int i = 0; i < totalCount; i++)
        {
            float sectionBegin = -range + sectionSize * i;
            weights[i] = CDF_Sum(sectionBegin, sectionBegin + sectionSize, delta);
            totalWeight += weights[i];
        }

        for (int i = 0; i < totalCount; i++)
        {
            weights[i] /= totalWeight;
        }


        float[] result = new float[count + 1];
        for (int i = count; i < totalCount; i++)
        {
            result[i - count] = weights[i];
        }

        return result;
    }

    void UpdateGaussianParamter()
    {
        float[] ga = GetGaussianArray(SampleCount, GaussianDelta);
        Mat.SetFloatArray("Gaussian_Weight", ga);
        Mat.SetInt("_Sample", SampleCount);

        m_prevGaussianDelta = GaussianDelta;
        m_prevSampleCount = SampleCount;
    }

    void CreateNewGaussianMat()
    {
        Mat = new Material(Shader.Find("Hidden/Gaussian"));
        UpdateGaussianParamter();
    }

    int m_prevSampleCount = 0;
    float m_prevGaussianDelta = 0;
    // Update is called once per frame
    void Update()
    {
        switch(Mode)
        {
            case E_FILTERMODE.Bilateral:
                if (m_prevSampleCount != SampleCount || m_prevGaussianDelta != GaussianDelta)
                {
                    CreateNewBilateralMat();
                }
                Mat.SetFloat("_BilateralSharpness", Sharpness);
                break;
            case E_FILTERMODE.Gaussian:
                if (m_prevSampleCount != SampleCount || m_prevGaussianDelta != GaussianDelta)
                {
                    CreateNewGaussianMat();
                }
                break;
        }
    }

    private void OnDestroy()
    {
        rt.Release();
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, rt, Mat, 0);
        Graphics.Blit(rt, destination, Mat, 1);
    }
}
