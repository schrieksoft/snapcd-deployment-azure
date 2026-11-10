
# first loop through resources in ids_prio[0]
resource "kustomization_resource" "p0" {
  for_each = data.kustomization_overlay.this.ids_prio[0]

  wait = false
  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.this.manifests[each.value])
    : data.kustomization_overlay.this.manifests[each.value]
  )
}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.p0
# wait 2 minutes for any deployment or daemonset to become ready
resource "kustomization_resource" "p1" {
  for_each = data.kustomization_overlay.this.ids_prio[1]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.this.manifests[each.value])
    : data.kustomization_overlay.this.manifests[each.value]
  )
  wait = var.wait_for_workloads

  timeouts {

    create = var.wait_for_workloads_timeout_create
    update = var.wait_for_workloads_timeout_update
  }

  depends_on = [kustomization_resource.p0]
}

# finally, loop through resources in ids_prio[2]
# and set an explicit depends_on on kustomization_resource.p1
resource "kustomization_resource" "p2" {
  for_each = data.kustomization_overlay.this.ids_prio[2]

  wait = false
  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.this.manifests[each.value])
    : data.kustomization_overlay.this.manifests[each.value]
  )

  depends_on = [kustomization_resource.p1]
}