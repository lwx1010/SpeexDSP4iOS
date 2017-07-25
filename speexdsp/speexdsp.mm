//
//  speexdsp.m
//  speexdsp
//
//  Created by @me on 15/5/26.
//  Copyright (c) 2015年 @me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "speex_preprocess.h"

SpeexPreprocessState *m_st;
static int preprocess_frame_size;
static int preprocess_sampling_rate;

#if defined (__cplusplus)
extern "C"
{
#endif
    void initprocess(int frame_size, int sampling_rate, float agc_level)
    {
        preprocess_frame_size = frame_size;
        preprocess_sampling_rate = sampling_rate;
        
        m_st = speex_preprocess_state_init(preprocess_frame_size, preprocess_sampling_rate);
        int denoise = 1;
        int noiseSuppress = -25;
        speex_preprocess_ctl(m_st, SPEEX_PREPROCESS_SET_DENOISE, &denoise);
        speex_preprocess_ctl(m_st, SPEEX_PREPROCESS_SET_NOISE_SUPPRESS, &noiseSuppress);
        
        int agc = 1;
        speex_preprocess_ctl(m_st, SPEEX_PREPROCESS_SET_AGC, &agc);
        speex_preprocess_ctl(m_st, SPEEX_PREPROCESS_SET_AGC_LEVEL, &agc_level);
    }
    
    short* preprocess(short* lin, int lin_size, short* out)
    {
        short* buffer = new short[preprocess_frame_size];
        short* output_buffer = new short[lin_size];
        int nsamples = (lin_size - 1) / preprocess_frame_size + 1;
        
        int p = 0;
        
        for (int i = 0; i < nsamples; i++)
        {
            int k = 0;
            memset(buffer, 0, preprocess_frame_size * sizeof(short));
            for (int j = i * preprocess_frame_size; j < i * preprocess_frame_size + preprocess_frame_size; j++)
            {
                buffer[k++] = lin[j];
            }
            spx_int16_t* ptr = (spx_int16_t*)buffer;
            speex_preprocess_run(m_st, ptr);
            for (int n = 0; n < preprocess_frame_size; n++)
            {
                output_buffer[p++] = buffer[n];
            }
        }
        
        for (int i = 0; i < lin_size; i++)
        {
            out[i] = output_buffer[i];
        }
        
        delete buffer;
        delete output_buffer;
        
        return out;
    }
    
    void closepreprocess()
    {
        speex_preprocess_state_destroy(m_st);
    }
    
#if defined(__cplusplus)
}
#endif



