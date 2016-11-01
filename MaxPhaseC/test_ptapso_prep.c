/* test function for ptapso.c */

#include <stdio.h>
#include "maxphase.h"
#include "ptapso_prep.h"
/* The header file tells us what fitness function we are calling
and what the parameter structure for this function is.
*/
#include "ptapsotestfunc.h"
#include <gsl/gsl_vector.h>
#include <gsl/gsl_errno.h>


/* structure encapsulating fitness function and its input parameters 
struct fitFuncStruct{
	struct inParamStruct{
		double yr;
		double s[];
		double xmaxmin[6][2];
		unsigned int Np;
	} inParams;
	double * (*fitFuncName)(double *[], struct inParams) = &LLR_PSOmpp;
}
*/



int main(){
	/* Number of search dimensions */
	unsigned int nDim = 3, lpc;
	double rmin[3] = {-5,-5,-5};
	double rmax[3] = {5, 5, 5};
	double rangeVec[3];
	
    /* Set up fitness function parameter struct. A subset of the fields
	   is universal to all fitness function.
	 */
	struct fitFuncParams inParams;
	inParams.rmin = gsl_vector_alloc(nDim);
	inParams.rangeVec = gsl_vector_alloc(nDim);
	inParams.realCoord = gsl_vector_alloc(nDim);
	inParams.nDim = nDim;
	/* Parameters specific to a fitness function can also be passed. */
	struct ptapsotestfunc_params spclParams;
	spclParams.dummyParam = 5;
	inParams.splParams = &spclParams;
	
	/* Error handling off */
	gsl_error_handler_t *old_handler = gsl_set_error_handler_off ();
	
	for (lpc = 0; lpc < nDim; lpc++){
		rangeVec[lpc]=rmax[lpc]-rmin[lpc];
		gsl_vector_set(inParams.rmin,lpc,rmin[lpc]);
		gsl_vector_set(inParams.rangeVec,lpc,rangeVec[lpc]);		
	}
	/* Set up pointer to fitness function. Use the prototype
	declaration given in the header file for the fitness function. */
	double (*fitfunc)(const gsl_vector *, void *) = ptapsotestfunc;
	
	/* Set up storage for output from ptapso. */
	struct returnData psoResults;
	double bestLocation[3];
	psoResults.bestLocation = bestLocation;
	
	/* Set up the pso parameter structure.*/
	struct psoParamStruct psoParams;
	psoParams.popsize=4;
	psoParams.maxSteps= 10; 
	psoParams.c1=2;
	psoParams.c2=2;
	psoParams.max_initial_velocity = 0.5;
	psoParams.max_velocity = 0.2;
	psoParams.dcLaw_a = 0.9;
	psoParams.dcLaw_b = 0.4;
	psoParams.dcLaw_c = psoParams.maxSteps;
	psoParams.dcLaw_d = 0.2;
	
	ptapso(fitfunc, &inParams, psoParams, &psoResults);
	
	/* Test local minimization routines in gsl: replacement of fminsearch */
	/* Free allocated memory */
	gsl_vector_free(inParams.rmin);
	gsl_vector_free(inParams.realCoord);
	gsl_vector_free(inParams.rangeVec);
}