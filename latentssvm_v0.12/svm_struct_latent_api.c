/************************************************************************/
/*                                                                      */
/*   svm_struct_latent_api.c                                            */
/*                                                                      */
/*   API function definitions for Latent SVM^struct                     */
/*                                                                      */
/*   Author: Chun-Nam Yu                                                */
/*   Date: 17.Dec.08                                                    */
/*                                                                      */
/*   This software is available for non-commercial use only. It must    */
/*   not be modified and distributed without prior permission of the    */
/*   author. The author is not responsible for implications from the    */
/*   use of this software.                                              */
/*                                                                      */
/************************************************************************/

#include <stdio.h>
#include <assert.h>
#include <math.h>
#include <string.h>
#include "svm_struct_latent_api_types.h"
#define MAX_INPUT_LINE_LENGTH 10000*1000*8

#define MIN_FRAME_LENGTH 20
#define MAX_FRAME_LENGTH 25

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

#define LOSS_VALUE 1

SAMPLE read_struct_examples(char *file, STRUCT_LEARN_PARM *sparm) {
/*
  Read input examples {(x_1,y_1),...,(x_n,y_n)} from file.
  The type of pattern x and label y has to follow the definition in 
  svm_struct_latent_api_types.h. Latent variables h can be either
  initialized in this function or by calling init_latent_variables(). 
*/
  SAMPLE sample;
  
  /* your code here */
	FILE *fp;
	char line[MAX_INPUT_LINE_LENGTH]; 
	if((fp = fopen(file, "r")) == NULL ) {
		printf("Cannot open input file %s!\n", file);
		exit(1);
	}
	char *token;
	
	int num_examples;
	int featureDim;
	int jointFeatureFrame;
	int actionNum;
	
	fgets(line, MAX_INPUT_LINE_LENGTH, fp);
	num_examples = atoi(line);
	sample.n = num_examples;
	printf("num_examples = %d\n", num_examples );
	
	sample.examples = (EXAMPLE*)malloc(sizeof(EXAMPLE)*num_examples);
	
	fgets(line, MAX_INPUT_LINE_LENGTH, fp);
	featureDim = atoi(line);
	sample.featureDim = featureDim;
	printf("featureDim = %d\n", featureDim );
		
	fgets(line, MAX_INPUT_LINE_LENGTH, fp);
	actionNum = atoi(line);
	sample.actionNum = actionNum;
	printf("actionNum = %d\n", actionNum );
		
	sample.jointFeatureFrame = sparm->jointFeatureFrame;
	printf("jointFeatureFrame = %d\n", sample.jointFeatureFrame );
	
	int i,j;
	for (i=0;i<num_examples;i++) {
		
		fgets(line, MAX_INPUT_LINE_LENGTH, fp);
		sample.examples[i].y.action = atoi(line);
		fgets(line, MAX_INPUT_LINE_LENGTH, fp);
		sample.examples[i].h.startFrame = atoi(line);
		fgets(line, MAX_INPUT_LINE_LENGTH, fp);
		sample.examples[i].h.endFrame = atoi(line);
		fgets(line, MAX_INPUT_LINE_LENGTH, fp);
		sample.examples[i].x.frameNum = atoi(line);
				
		printf("action = %d\n", sample.examples[i].y.action );
		printf("startFrame = %d\n", sample.examples[i].h.startFrame );
		printf("endFrame = %d\n", sample.examples[i].h.endFrame );
		printf("frameNum = %d\n", sample.examples[i].x.frameNum );
		
		//error check
		if (sample.examples[i].h.startFrame-sample.examples[i].h.endFrame+1 > sample.examples[i].x.frameNum ){
			printf("startFrame-endFrame > frameNum\n");
			exit(1);
		}
		
		sample.examples[i].x.allfeatures = (double*)malloc(sizeof(double)*featureDim*sample.examples[i].x.frameNum);
		fgets(line, MAX_INPUT_LINE_LENGTH, fp);
		token = strtok( line, "," );		
		for( j=0; j<featureDim*sample.examples[i].x.frameNum; j++ ){
			sample.examples[i].x.allfeatures[j] = atof( token );
			token = strtok (NULL, ",");
		}
	}	
	
	fclose(fp);
	
  return(sample); 
}

void init_struct_model(SAMPLE sample, STRUCTMODEL *sm, STRUCT_LEARN_PARM *sparm, LEARN_PARM *lparm, KERNEL_PARM *kparm) {
/*
  Initialize parameters in STRUCTMODEL sm. Set the diminension 
  of the feature space sm->sizePsi. Can also initialize your own
  variables in sm here. 
*/
	sm->featureDim = sample.featureDim;
	sm->jointFeatureFrame = sample.jointFeatureFrame;
	sm->actionNum = sample.actionNum;
	sm->sizePsi = ( sm->jointFeatureFrame * sm->featureDim + 1 ) * sm->actionNum; /* replace with appropriate number */
  
  sm->n = sample.n;
  
  /* your code here*/

}

void init_latent_variables(SAMPLE *sample, LEARN_PARM *lparm, STRUCTMODEL *sm, STRUCT_LEARN_PARM *sparm) {
/*
  Initialize latent variables in the first iteration of training.
  Latent variables are stored at sample.examples[i].h, for 1<=i<=sample.n.
*/

  /* your code here */
}

void calcJointFeature( double *jointFeature, double* subFeature, int totalFrameNum, int featureDim, int jointFeatureFrame )
{	
	// compute jointFeature from subFeature
	const double multiplier = 0.01;	
	int t;
	int d;
	double tInterpolate;
	int t1,t2;
	double ratio = totalFrameNum / jointFeatureFrame;
	for( t=0; t<jointFeatureFrame; t++ ){
		for( d=0; d<featureDim; d++ ){
			tInterpolate = t*ratio;
			t1 = floor(tInterpolate);
			t2 = ceil(tInterpolate);
			if (t1==t2){
				jointFeature[d+t*featureDim] = subFeature[d+(t1)*featureDim] * multiplier;
			}else{
				jointFeature[d+t*featureDim] = ( subFeature[d+(t1)*featureDim] * ( t2 - tInterpolate ) + subFeature[d+(t2)*featureDim] * ( tInterpolate - t1 ) ) * multiplier;	
			}
		}
	}
	jointFeature[featureDim*jointFeatureFrame] = 1 * multiplier;
}

SVECTOR *psi(PATTERN x, LABEL y, LATENT_VAR h, STRUCTMODEL *sm, STRUCT_LEARN_PARM *sparm) {
/*
  Creates the feature vector \Psi(x,y,h) and return a pointer to 
  sparse vector SVECTOR in SVM^light format. The dimension of the 
  feature vector returned has to agree with the dimension in sm->sizePsi. 
*/
  SVECTOR *fvec=NULL;  
  
  /* your code here */
  double* jointFeature = (double*)malloc(sizeof(double)*sm->sizePsi  );
  memset( jointFeature, 0, sizeof(double)*sm->sizePsi );
  double* tempFeature = (double*)malloc(sizeof(double)*(sm->featureDim*sm->jointFeatureFrame + 1) );
  
  calcJointFeature( tempFeature, &(x.allfeatures[sm->featureDim*h.startFrame]), h.endFrame - h.startFrame + 1, sm->featureDim, sm->jointFeatureFrame );
  
  memcpy( &jointFeature[y.action * (sm->featureDim*sm->jointFeatureFrame+1)], tempFeature, sizeof(double)*(sm->featureDim*sm->jointFeatureFrame+1) );
  
  // convert jointFeature to words
  WORD *words = (WORD*)my_malloc(sizeof(WORD)*(sm->sizePsi+1));
  
  int i;
  for (i=0;i<sm->sizePsi;i++) {
    words[i].wnum = i+1;
	words[i].weight = (double) jointFeature[i];
  }
  words[i].wnum=0;
  words[i].weight=0.0;
  fvec = create_svector(words,"",1);  
  
  free(words);
  free(jointFeature);
  free(tempFeature);
  
  
  return(fvec);
}

LATENT_VAR infer_latent_variables(PATTERN x, LABEL y, STRUCTMODEL *sm, STRUCT_LEARN_PARM *sparm) {
/*
  Complete the latent variable h for labeled examples, i.e.,
  computing argmax_{h} <w,psi(x,y,h)>. 
*/

  LATENT_VAR h;
  
  /* your code here */
  int s;
  int e;
  int i;
  double maxScore=-DBL_MAX;
  int maxS;
  int maxE;
  double* subJointFeature = (double*)malloc(sizeof(double)*(sm->featureDim*sm->jointFeatureFrame+1));
  for( s=0; s<x.frameNum-MIN_FRAME_LENGTH;s++){
	for( e=s+MIN_FRAME_LENGTH-1; e<MIN(s+MAX_FRAME_LENGTH, x.frameNum);e++ ){
		calcJointFeature( subJointFeature, &(x.allfeatures[sm->featureDim*s]), e - s + 1, sm->featureDim, sm->jointFeatureFrame );
		double score=0;
		for( i=0;i<sm->featureDim*sm->jointFeatureFrame+1;i++){
			score = score + subJointFeature[i] * sm->w[1+y.action*(sm->featureDim*sm->jointFeatureFrame+1)+i]; //sm->w[0] is always 0 for some implementation issue. See create_nvector in svm_common.c
		}
		//printf("score=%f\n", score );
		if (score > maxScore){
			maxScore = score;
			maxS = s;
			maxE = e;
		}
	}
  }
  
  h.startFrame = maxS;
  h.endFrame = maxE;
  h.score = maxScore;

  free(subJointFeature);
  
  printf("(s,e)=(%d,%d,%f)\n", h.startFrame, h.endFrame, h.score );
  
  return(h); 
}

void classify_struct_example(PATTERN x, LABEL *y, LATENT_VAR *h, STRUCTMODEL *sm, STRUCT_LEARN_PARM *sparm) {
/*
  Makes prediction with input pattern x with weight vector in sm->w,
  i.e., computing argmax_{(y,h)} <w,psi(x,y,h)>. 
  Output pair (y,h) are stored at location pointed to by 
  pointers *y and *h. 
*/
  
  /* your code here */ 
	int a;
    double maxScore=-DBL_MAX;
	int maxAction;
	LATENT_VAR maxLatentVar;
	LABEL label;
	LATENT_VAR latent;
	for( a=0;a<sm->actionNum;a++){
		label.action = a;
		latent = infer_latent_variables( x, label, sm, sparm);
		if( latent.score > maxScore ){
			maxScore = latent.score;
			maxLatentVar = latent;
			maxAction = a;
		}
	}
	
	h->startFrame = maxLatentVar.startFrame;
	h->endFrame = maxLatentVar.endFrame;
	y->action = maxAction;
	
}

double loss(LABEL y, LABEL ybar, LATENT_VAR hbar, STRUCT_LEARN_PARM *sparm) {
/*
  Computes the loss of prediction (ybar,hbar) against the
  correct label y. 
*/
  /* your code here */

  if (y.action==ybar.action) {
    return(0);
  } else {
    return(LOSS_VALUE);
  }
}

void find_most_violated_constraint_marginrescaling(PATTERN x, LABEL y, LABEL *ybar, LATENT_VAR *hbar, STRUCTMODEL *sm, STRUCT_LEARN_PARM *sparm) {
/*
  Finds the most violated constraint (loss-augmented inference), i.e.,
  computing argmax_{(ybar,hbar)} [<w,psi(x,ybar,hbar)> + loss(y,ybar,hbar)].
  The output (ybar,hbar) are stored at location pointed by 
  pointers *ybar and *hbar. 
*/

  /* your code here */
	int a;
    double maxScore=-DBL_MAX;
	int maxAction;
	double loss;
	LATENT_VAR maxLatentVar;
	LATENT_VAR latent;
	LABEL label;
	for( a=0;a<sm->actionNum;a++){
		label.action = a;
		latent = infer_latent_variables( x, label, sm, sparm);
				
		if (y.action==a) {
			loss = 0;
		} else {
			loss = LOSS_VALUE;
		}
  
		latent.score = latent.score + loss;
		
		if( latent.score > maxScore ){
			maxScore = latent.score;
			maxLatentVar = latent;
			maxAction = a;
		}
	}
	
	hbar->startFrame = maxLatentVar.startFrame;
	hbar->endFrame = maxLatentVar.endFrame;
	ybar->action = maxAction;
	
}






void write_struct_model(char *file, STRUCTMODEL *sm, STRUCT_LEARN_PARM *sparm) {
/*
  Writes the learned weight vector sm->w to file after training. 
*/
	FILE *modelfl;
	int i;

	modelfl = fopen(file,"w");
	if (modelfl==NULL) {
		printf("Cannot open model file %s for output!", file);
		exit(1);
	}

	/* write model information */
	fprintf(modelfl, "%d\n", sm->sizePsi ); 
	for (i=1;i<sm->sizePsi+1;i++) {
		fprintf(modelfl, "%d:%.16g\n", i, sm->w[i]);
	}
	fclose(modelfl);
}

STRUCTMODEL read_struct_model(char *file, STRUCT_LEARN_PARM *sparm) {
/*
  Reads in the learned model parameters from file into STRUCTMODEL sm.
  The input file format has to agree with the format in write_struct_model().
*/
  STRUCTMODEL sm;

  /* your code here */
  FILE *modelfl;
  int i, fnum;
  double fweight;
    
  modelfl = fopen(file,"r");
  if (modelfl==NULL) {
    printf("Cannot open model file %s for input!", file);
	exit(1);
  } 
  
  fscanf(modelfl, "%d", &(sm.sizePsi) );
  printf("sizePsi=%d\n", sm.sizePsi );

  sm.w = (double*)malloc( (sm.sizePsi+1) * sizeof(double) ); 

  if ( sm.w == NULL ){
	printf("Fail to allocate memory.\n");
	exit(1);
  }
  
  for (i=0;i<sm.sizePsi+1;i++) {
    sm.w[i] = 0.0;
  }
  
  while (!feof(modelfl)) {
    fscanf(modelfl, "%d:%lf", &fnum, &fweight);
	sm.w[fnum] = fweight;
	printf("%d, %.16g\n", fnum, fweight);
  }
    
  fclose(modelfl);  
  
  return(sm);
}

void free_struct_model(STRUCTMODEL sm, STRUCT_LEARN_PARM *sparm) {
/*
  Free any memory malloc'ed in STRUCTMODEL sm after training. 
*/

  /* your code here */
  
  free(sm.w);
}

void free_pattern(PATTERN x) {
/*
  Free any memory malloc'ed when creating pattern x. 
*/

  /* your code here */
	free(x.allfeatures);
}

void free_label(LABEL y) {
/*
  Free any memory malloc'ed when creating label y. 
*/

  /* your code here */

} 

void free_latent_var(LATENT_VAR h) {
/*
  Free any memory malloc'ed when creating latent variable h. 
*/

  /* your code here */

}

void free_struct_sample(SAMPLE s) {
/*
  Free the whole training sample. 
*/
  int i;
  for (i=0;i<s.n;i++) {
    free_pattern(s.examples[i].x);
    free_label(s.examples[i].y);
    free_latent_var(s.examples[i].h);
  }
  free(s.examples);

}

void parse_struct_parameters(STRUCT_LEARN_PARM *sparm) {
/*
  Parse parameters for structured output learning passed 
  via the command line. 
*/
  int i;
  
  /* set default */
  sparm->jointFeatureFrame = 20;
  
  for (i=0;(i<sparm->custom_argc)&&((sparm->custom_argv[i])[0]=='-');i++) {
    switch ((sparm->custom_argv[i])[2]) {
      /* your code here */
      default: printf("\nUnrecognized option %s!\n\n", sparm->custom_argv[i]); exit(0);
	  case 'j': i++; sparm->jointFeatureFrame = atoi(sparm->custom_argv[i]); break;
	
    }
  }
}

