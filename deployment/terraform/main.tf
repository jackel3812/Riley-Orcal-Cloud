# Oracle Cloud Deployment Package
resource "oci_core_instance" "riley_instance" {
    availability_domain = "AD-1"
    compartment_id = "ocid1.tenancy.oc1..aaaaaaaaiutl4m2magmp3omxuu5ih7p4zyi3cyyhchtfpcakcizqrhchlxhq"
    display_name = "riley-server"
    shape = "VM.Standard.E5.Flex"
    
    shape_config {
        ocpus = 2
        memory_in_gbs = 16
    }
    
    source_details {
        source_type = "image"
        source_id = "Oracle-Linux-7.9-2025.04.16-0"
    }

    create_vnic_details {
        subnet_id = "ocid1.vcn.oc1.iad.amaaaaaai363nmaat374jterqg2rw2uqousqymy4qeg74l2xm3hswueb7azq"
        assign_public_ip = true
    }

    metadata = {
        ssh_authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5PCtntbz09mqSejWbX9pAZaXvPlzWEv0YhQ2VnDEZHH1mIxFC9UxBahpO3iRI2UzpvdTytTk5AHKLyPGkgrZdmdssC14BmuJOHyTb7/KKZRckpzgh9ANY84PJmKzd3sHLZzijMGT1krcVFkdEepBhNXjsAqLNslQ/a2wFAErqJ2rbvMmCFI+yDs5322uWb8vgKDA5durivpCeCUJ7X3994ON0rjrUXJMkAej+kHgRHUC8VKhP68mHDkicpSOpcVJZSoDstmh7KWhr1Tn5xfSBZE6ifp4m95zaCGmd6/yi6m/eEt15ymr9GpyIjinf1H8SsTzbPrlJ/VmDVPhMnmSh andrewtoka@c5c30063d071"
    }
}
