# you need to at least v5.0.0 of kustomize for the below
rm -rf ../base
kustomize localize . ../base

# The above takes the form of
# kustomize localize [path of the kustomization file; in this case "." denotes the current folder] [where to write out the localizations toe]