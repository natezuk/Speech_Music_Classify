# Speech_Music_Classify

Experiment and analysis to classify speech and music sounds from 2 s of EEG data.  

Subjects will be presented continuously with 2 s clips of sounds.  The sounds will be speech, music, or "non-vocal human" sounds that are sparse and have strong onsets, such as impact sounds.  "Scrambled" versions of the sounds with identical statistics (using McDermott & Simoncelli's 2011 model) will also be presented.  The task will be a one-back task, subjects will be asked to identify if the current sound is identical to sound before the previous sound.

We will determine how well each of these sounds can be classified using multiclass linear discriminant analysis based on the 2 s of EEG data for each sound.  Our previous work has shown that speech, music, and these "non-vocal human" sounds classify better than other environment sounds.  We hypothesize that be scrambling the sounds, scrambled speech and music will classify worse, while the scrambled non-vocal human sounds with classify the same since they will have the same onset-like properties as the originals.

(2-9-2019)
All analysis code for Experiment 1 was run on data collected and preprocessed by Emily Teoh.  Experiment 2 was inspired by the result from Teoh's experiment, where subjects listened to various natural sounds, including speech and music.  We found that, using multi-class LDA, speech, music, and impact sounds were classified better than all other natural sounds.