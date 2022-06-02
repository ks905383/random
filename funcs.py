import xarray as xr
import numpy as np

def sig_fdr(ps: xr.core.dataarray.DataArray,FDR=0.2) -> xr.core.dataarray.DataArray:
    ''' Calculate field significance contingent on a given FDR
    Adapted from Wilks 2016: "'The Stippling Shows Statistically 
    Significant Grid Points': How Research Results are Routinely 
    Overstated and Overinterpreted, and What to Do about it"
    
    Parameters 
    -----------------------
    ps : xr.DataArray
        a DataArray of significance values over some grid containing
        lat / lon, and any optional number of other dimensions
    
    FDR : float (default 0.2) 
        the desired false discovery rate (FDR)
    
    Returns 
    -----------------------
    sigTests : xr.DataArray
        a DataArray of booleans showing whether a pixel is significant
        based on a given FDR
    ''' 
    if type(ps) != xr.core.dataarray.DataArray:
        raise TypeError('`ps` must be an xarray DataArray.')
    
    # stack geographic variables into one
    ps_stack = ps.stack(loc=('lat','lon'))
    
    # calculate (i/N)*a_fdr, where i is the rank, N is the 
    # number of pixels (highest rank gets it; otherwise would
    # be a count of non-nans, which might be faster but uglier), 
    # and a_fdr is the significance marker
    sigLevel = (ps_stack.rank('loc')/ps_stack.rank('loc').max('loc'))*FDR

    # significant pixels are those where
    # p < p_fdr = max{p(i):p(i) < (i/N)a_fdr}
    sigTests = ps_stack < ps_stack.where(ps_stack < sigLevel).max('loc')
    # restore nans, which are removed through the < 
    sigTests = sigTests.where(~np.isnan(ps_stack))
    
    # unstack and return
    sigTests = sigTests.unstack()
    return sigTests
