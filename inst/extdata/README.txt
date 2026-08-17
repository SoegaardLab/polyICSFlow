Data provenance and preparation

The example FCS file included in this directory was derived from flow
cytometry data generated as part of a clinical trial. The original FCS files
cannot be publicly distributed because they are subject to clinical trial
data-access restrictions.

The original FCS files were transformed using estimateLogicle and pre-gated
to exclude debris, dead cells, doublets, and non-lymphocytes. Low-quality
events were subsequently removed using PeacoQC.

CD8 T cells were identified from the lymphocyte population using FlowSOM
clustering based on CD3, CD4, CD8, CD16, and CD19 expression. The
CD3+CD8+CD4-CD16-CD19- FlowSOM metacluster was selected, and the resulting
CD8 T-cell population was exported as the FCS file provided in this
directory.

Because the original clinical trial data cannot be publicly accessed, the
complete preprocessing workflow cannot be reproduced from the raw data.
However, the steps above describe how the example data included with the
package were obtained and prepared.

Source: doi: 10.1038/s41591-022-02023-7