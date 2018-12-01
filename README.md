# TIFR_Project_Pattern_Matching
TIFR Project on Automatic Speech Recognition using Dynamic Time Warping and Pattern Recognition 
Project Topic:
To recognize the movie names spoken by a user from a selected set of movie names. It should then retrieve the recognized movie from a directory on the local disk and play it out using a video player. 
Automatic Speech recognition
 Automated speech recognition (ASR) is a technology that allows users of information systems to speak entries rather than punching numbers on a keypad. A system is trained with a set of vocabulary which is can detect the vocabulary words when spoken by the user. 
Example:  
Name dialing in phones, IVRs in telephony applications, User interfacing systems in hotels, etc.
SHORT TIME PROCESSING
Short time processing refers to analysis of speech signal by blocking speech into frames and then studying each frame separately. Each frame has a definite size referred to as frame size. After the first frame is analyzed the frame is shifted with a measure of frame shift. Frame Shift is always lesser than frame size.
In this project the frame size is 0.025 seconds and frame shift is 0.01 seconds.

CEPSTRAL ANALYSIS
 
The power cepstrum of a signal is defined as the squared magnitude of the inverse Fourier transform of the logarithm of the squared magnitude of the Fourier transform of a signal. A short-time cepstrum analysis was proposed by Schroeder and Noll for application to pitch determination of human speech.
Mel Frequency Cepstral Coefficients (MFCC)
Mel-frequency cepstral coefficients (MFCCs) are coefficients that collectively make up an MFC. They are derived from a type of cepstral representation of the audio.

Speech Signal Processing (Feature Extraction)

The analog speech signal is sampled called digitization of analog speech signal. The sampled signal is blocked signal into frames.  The signal is undergone Fourier Transform (FFT) and is filtered. The filtered frames are undergone logarithm transform and then inverse Fourier transform.  Then feature extraction captures first thirteen cepstral coefficients which are saved as MFCC. The sequence of feature vectors (x1, x2, x3……xT) and are saved as cepstrum vectors. Then frame is shifted by a set frame shift value and the analysis is done for the next subsequent frame.  All cepstrum vectors (feature vectors) are arranged in a form of matrix with nFrame (number of frames) columns and 13 rows. Thus each speech wave creates a cepstrum Matrix.

PATTERN RECOGNITION AND OPTIMAL ALIGNMENT PATH

Formant Frequencies – 
A formant is a concentration of acoustic energy around a particular frequency in the speech wave. There are several formants, each at a different frequency, roughly one in each 1000Hz band. Or, to put it differently, formants occur at roughly 1000Hz intervals. Each formant corresponds to a resonance in the vocal tract.

OPTIMAL ALIGNMENT PATH
Our goal is to find the optimal alignment path from the grid point (1, 1) to the grid point (N, M). There are exponential number (MN) of paths. In order to reduce the number of computations from exponential to linear, we use the dynamic programming whose foundation is the “principle of optimality”.

Principle of optimality: The best path from (1, 1) to any given point in the grid is independent of what happens beyond the point.

So, if two paths share a partial path starting from (1, 1), the cost of the shared partial path need to be computed only once and stored in a table for later use.
 
 Distance Calculation--->
 
d (n, m) = the local distance between the nth test frame and mth reference frame.
D (n, m) = the accumulated distance of the optimal path starting from the grid point (1, 1) and ending at the grid point (n, m).

Figure: Example of optimal alignment path between two words.


Dynamic Time Warping-
Dynamic time warping is an approach that was historically used for speech recognition but has now largely been displaced by the more successful HMM-based approach.
Dynamic time warping is an algorithm for measuring similarity between two sequences that may vary in time or speed. For instance, similarities in walking patterns would be detected, even if in one video the person was walking slowly and if in another he or she were walking more quickly, or even if there were accelerations and deceleration during the course of one observation. DTW has been applied to video, audio, and graphics – indeed, any data that can be turned into a linear representation can be analyzed with DTW.

Applying the principle of optimality, D (n, m) is the sum of the local cost, and the cheapest path to it.
That means,

D (n, m) = d (n, m) + min 

Compute D (n, m) for each ‘allowed pair’ of (n, m).
Remember the ‘best’ predecessor point.
D (N, M) is the cost of optimal path. From (N, M), start back tracking to identify the optimal path.


Why speech recognition is difficult?
	Speaker specific – physiological, emotional, cultural
	Continuous signal – no well-defined boundaries between linguistic units
	Ambience – noise, Lombard Effect, room acoustics
	Channel – additive/convolutional noise, compression
	Transducer – omni/uni-directional, carbon 
	Phonetic Context

