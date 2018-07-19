% AS_VECTOR turn any array into a vector
%   For those of you who use R, as.vector can be a useful tool to vectorize
%   scripts. In MATLAB, an easy built-in version exists as the (:)
%   operator, but it only works if the array in question isn't being
%   otherwise manipulated before being turned into a vector (i.e. X(:)
%   vectorizes X, but there is no way to do the same thing in one command
%   for, say, X(1:5,:,:)). AS_VECTOR solves this issue by merely
%   returning the input array reshaped into a 1D vector, providing a
%   one-line and more elegant solution to what would otherwise require a
%   second step and an intermediary variable. 
%
%   vec = AS_VECTOR(invec) returns invec(:)
%
%   For questions/comments, contact Kevin Schwarzwald
%   kschwarzwald@uchicago.edu
%   Last edit: 04/01/2018

function vec = as_vector(invec)

vec = invec(:);
end