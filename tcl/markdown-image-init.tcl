ad_library {
    Clean up abandoned pasted News images.
}

ad_schedule_proc -thread t 3600 ::news::markdown_image::expire_drafts
