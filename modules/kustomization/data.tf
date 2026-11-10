# based on https://github.com/kbst/catalog/blob/master/src/_terraform_module/data_source.tf


data "kustomization_overlay" "this" {
  resources = var.absolute_paths

  common_annotations = var.common_annotations
  common_labels      = var.common_labels
  components         = var.components
  crds               = var.crds
  generators         = var.generators
  name_prefix        = var.name_prefix
  namespace          = var.namespace
  name_suffix        = var.name_suffix
  transformers       = var.transformers

  dynamic "config_map_generator" {
    for_each = var.config_map_generators != null ? var.config_map_generators : []
    iterator = i
    content {
      name      = i.value["name"]
      namespace = i.value["namespace"]
      behavior  = i.value["behavior"]
      envs      = i.value["envs"]
      files     = i.value["files"]
      literals  = i.value["literals"]
      options {
        labels                   = lookup(i.value, "options") != null ? i.value["options"]["labels"] : null
        annotations              = lookup(i.value, "options") != null ? i.value["options"]["annotations"] : null
        disable_name_suffix_hash = lookup(i.value, "options") != null ? i.value["options"]["disable_name_suffix_hash"] : null
      }
    }
  }

  dynamic "generator_options" {
    for_each = var.generator_options != null ? toset([var.generator_options]) : toset([])
    iterator = i
    content {
      labels                   = i.value["labels"]
      annotations              = i.value["annotations"]
      disable_name_suffix_hash = i.value["disable_name_suffix_hash"]
    }
  }

  dynamic "images" {
    for_each = var.images != null ? var.images : []
    iterator = i
    content {
      name     = i.value["name"]
      new_name = i.value["new_name"]
      new_tag  = i.value["new_tag"]
      digest   = i.value["digest"]
    }
  }

  dynamic "secret_generator" {
    for_each = var.secret_generators != null ? var.secret_generators : []
    iterator = i
    content {
      name      = i.value["name"]
      namespace = i.value["namespace"]
      behavior  = i.value["behavior"]
      type      = i.value["type"]
      envs      = i.value["envs"]
      files     = i.value["files"]
      literals  = i.value["literals"]
      options {
        labels                   = lookup(i.value, "options") != null ? i.value["options"]["labels"] : null
        annotations              = lookup(i.value, "options") != null ? i.value["options"]["annotations"] : null
        disable_name_suffix_hash = lookup(i.value, "options") != null ? i.value["options"]["disable_name_suffix_hash"] : null
      }
    }
  }

  dynamic "patches" {
    for_each = var.patches != null ? var.patches : []
    iterator = i
    content {
      patch = i.value["patch"]
      path  = i.value["path"]

      dynamic "target" {
        for_each = i.value["target"] != null ? toset([i.value["target"]]) : toset([])
        iterator = j
        content {
          group               = j.value["group"]
          version             = j.value["version"]
          kind                = j.value["kind"]
          name                = j.value["name"]
          namespace           = j.value["namespace"]
          label_selector      = j.value["label_selector"]
          annotation_selector = j.value["annotation_selector"]
        }
      }
    }
  }

  dynamic "replicas" {
    for_each = var.replicas != null ? var.replicas : []
    iterator = i
    content {
      name  = i.value["name"]
      count = i.value["count"]
    }
  }

  dynamic "vars" {
    for_each = var.vars != null ? var.vars : []
    iterator = i
    content {
      name = i.value["name"]

      dynamic "obj_ref" {
        for_each = i.value["obj_ref"] != null ? toset([i.value["obj_ref"]]) : toset([])
        iterator = j
        content {
          group       = j.value["group"]
          version     = j.value["version"]
          kind        = j.value["kind"]
          name        = j.value["name"]
          namespace   = j.value["namespace"]
          api_version = j.value["api_version"]
        }
      }

      dynamic "field_ref" {
        for_each = i.value["field_ref"] != null ? toset([i.value["field_ref"]]) : toset([])
        iterator = j
        content {
          field_path = j.value["field_path"]
        }
      }
    }
  }

}

