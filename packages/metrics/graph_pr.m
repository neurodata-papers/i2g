function metrics = graph_pr_(lgTruth, lgTest)
% This function assumes that line graphs have only integer values (i.e.,
% post thresholding).  Thresholding or curve construction should happen as
% a wrapper to this function.  Line graphs are first binarized for
% simplicity

lgTruth = lgTruth + lgTruth';
lgTruth = lgTruth > 0;
lgTest = lgTest > 0;

metrics.tp = length(find(lgTruth == 1 & lgTest == 1));
metrics.fp = length(find(lgTruth == 0 & lgTest == 1));
metrics.fn = length(find(lgTruth == 1 & lgTest == 0));
metrics.tn = length(find(lgTruth == 0 & lgTest == 0));

metrics.precision = metrics.tp./(metrics.tp+metrics.fp);
metrics.recall = metrics.tp./(metrics.tp+metrics.fn);
metrics.f1 = 2*(metrics.precision*metrics.recall)...
                    /(metrics.precision+metrics.recall);