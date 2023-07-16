#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec4 uColor;
uniform float uWidth;
uniform sampler2D uTexture;

out vec4 fragColor;

float normalProbabilityDensityFunction(float x, float sigma) {
    return 0.39894 * exp(-0.5*x*x / (sigma*sigma)) / sigma;
}

vec4 gaussianBlur() {
    // The gaussian operator size
    // The higher this number, the better quality the outline will be
    // But this number is expensive! O(n2)
    const int matrixSize = 11;

    vec2 UV = FlutterFragCoord().xy/uSize.xy;
    
    // How far apart (in UV coordinates) are each cell in the Gaussian Blur
    // Increase this for larger outlines!
    vec2 offset = vec2(uWidth, uWidth);
    
    const int kernelSize = (matrixSize-1)/2;
    float kernel[matrixSize];
    
    // Create the 1-D kernel using a sigma
    float sigma = 7.0;
    for (int j = 0; j <= kernelSize; ++j)
    {
        kernel[kernelSize+j] = kernel[kernelSize-j] = normalProbabilityDensityFunction(float(j), sigma);
    }
    
    // Generate the normalization factor
    float normalizationFactor = 0.0;
    for (int j = 0; j < matrixSize; ++j)
    {
        normalizationFactor += kernel[j];
    }
    
    normalizationFactor = normalizationFactor * normalizationFactor;
    
    // Apply the kernel to the fragment
    vec4 outputColor = vec4(0.0);

    for (int i=-kernelSize; i <=kernelSize; ++i) {
        for (int j=-kernelSize; j<=kernelSize; ++j) {
          float kernelValue = kernel[kernelSize+j]*kernel[kernelSize+i];
          vec2 sampleLocation = UV.xy + vec2(float(i) * offset.x, float(j) * offset.y);
          vec4 textureSample = texture(uTexture, sampleLocation);
          outputColor =  outputColor + (kernelValue * textureSample);
        }
    }
    
    // Divide by the normalization factor, so the weights sum to 1
    outputColor = outputColor/(normalizationFactor*normalizationFactor);
    
    return outputColor;
}

void main(void) {
    vec2 UV = FlutterFragCoord().xy/uSize.xy;

    // After blurring, what alpha threshold should we define as outline?
    float alphaTreshold = 0.3;
    
    // How smooth the edges of the outline it should have?
    float outlineSmoothness = 0.1;
    
    
    // Sample the original image and generate a blurred version using a gaussian blur
    vec4 originalImage = texture(uTexture, UV);
    vec4 blurredImage = gaussianBlur();
    
    
    float alpha = smoothstep(alphaTreshold - outlineSmoothness, alphaTreshold + outlineSmoothness, blurredImage.a);
    vec4 outlineFragmentColor = mix(vec4(0.0), uColor, alpha);
    
    fragColor = mix(outlineFragmentColor, originalImage, originalImage.a);
}

