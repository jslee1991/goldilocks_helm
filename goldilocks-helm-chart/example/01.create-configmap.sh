kubectl create cm goldilock-configmap \
 --from-file=goldilocks.properties.conf \
 --from-file=goldilocks0-0.license \
 --from-file=goldilocks0-1.license \
 --from-file=goldilocks0-2.license \
 --from-file=goldilocks1-0.license \
 --from-file=goldilocks1-2.license \
 --from-file=goldilocks1-3.license \
 --from-file=logind.conf
