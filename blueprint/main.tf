terraform {
  required_providers {
    genesyscloud = {
      source = "mypurecloud/genesyscloud"
    }
  }
}



provider "genesyscloud" {
  sdk_debug = true
}

data "genesyscloud_user" "mattydonuts" {
  email = "mathew.danish@genesys.com"
}

resource "genesyscloud_routing_queue" "queue_ira" {
  name                     = "Simple Financial IRA queue mat"
  description              = "Simple Financial IRA questions and answers"
  acw_wrapup_prompt        = "MANDATORY_TIMEOUT"
  acw_timeout_ms           = 300000
  skill_evaluation_method  = "BEST"
  auto_answer_only         = true
  enable_transcription     = true
  enable_manual_assignment = true

  members {
    user_id  = data.genesyscloud_user.mattydonuts.id
    ring_num = 1
  }
}

resource "genesyscloud_routing_queue" "queue_K401" {
  name                     = "Simple Financial 401K queue mat"
  description              = "Simple Financial 401K questions and answers"
  acw_wrapup_prompt        = "MANDATORY_TIMEOUT"
  acw_timeout_ms           = 300000
  skill_evaluation_method  = "BEST"
  auto_answer_only         = true
  enable_transcription     = true
  enable_manual_assignment = true
  members {
    user_id  = data.genesyscloud_user.mattydonuts.id
    ring_num = 1
  }
}

resource "genesyscloud_flow" "mysimpleflow" {
  filepath = "./SimpleFinancialIvrmat_v2-0.yaml"
  file_content_hash = filesha256("./SimpleFinancialIvrmat_v2-0.yaml") 
}


resource "genesyscloud_telephony_providers_edges_did_pool" "mygcv_number" {
  start_phone_number = var.my_ivr_did_number
  end_phone_number   = var.my_ivr_did_number
  description        = "GCV Number for inbound calls"
  comments           = "Additional comments"
}

resource "genesyscloud_architect_ivr" "mysimple_ivr" {
  name               = "A simple IVR1"
  description        = "A sample IVR configuration"
  dnis               = [var.my_ivr_did_number, var.my_ivr_did_number]
  open_hours_flow_id = genesyscloud_flow.mysimpleflow.id
  depends_on         = [
    genesyscloud_flow.mysimpleflow,
    genesyscloud_telephony_providers_edges_did_pool.mygcv_number
  ]
}

