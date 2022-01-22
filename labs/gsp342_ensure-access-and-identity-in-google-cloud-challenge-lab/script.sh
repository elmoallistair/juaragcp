##################################################################################################
#Task 1: Create a custom security role.
#Buka Cloud Shell dan buat file konfigurasi misal : role-definition.yaml
nano role-definition.yaml
#---Copy paste teks di bawah ini kedalam file role-definition.yaml hapus tanda # pada awal baris---
#title: "Silakan isi title Anda"
#description: "Silakan isi description Anda"
#includedPermissions:
#- storage.buckets.get
#- storage.objects.get
#- storage.objects.list
#- storage.objects.update
#- storage.objects.create
#--------------------------------------------------------------------------------------------------
#Selanjutnya eksekusi script di bawah ini untuk membuat custom role
gcloud iam roles create [GANTI_DENGAN_NAMA_CUSTOM_ROLE_YANG_DIMINTA] \
   --project $DEVSHELL_PROJECT_ID \
   --file role-definition.yaml
##################################################################################################


##################################################################################################
#Task 2: Create a service account
#dan
#Task 3: Bind a custom security role to an account
#Pada halaman browser Google Cloud Console pilih menu IAM & Admin
#Selanjutnya pilih Service Accounts
#Pilih Create Service Account
#Isi form pembuatan service account dengan ketentuan sebagai berikut :
#Service account name : [ISI_DENGAN_NAMA_SERVICE_ACCOUNT_YANG DIMINTA] misal : orca-private-cluster-263-sa
#Isi Roles dengan : orca_....
#Tambahkan Roles : Monitoring Viewer, Monitoring Metric Write, dan Logs Writer
#Klik Continue
#Klik Done
##################################################################################################

##################################################################################################
#Task 4: Create and configure a new Kubernetes Engine private cluster
#Pada Cloud Shell ketik perintah di bawah ini :
gcloud container clusters create [GANTI_DENGAN_NAMA_CLUSTER_YANG_DIMINTA] \
   --num-nodes 1\
   --master-ipv4-cidr=172.16.0.64/28 \
   --network orca-build-vpc \
   --subnetwork orca-build-subnet \
   --enable-master-authorized-networks \
   --master-authorized-networks 192.168.10.2/32 \
   --enable-ip-alias \
   --enable-private-nodes \
   --enable-private-endpoint \
   --service-account [GANTI_DENGAN_NAMA_SERVICE_ACCOUNT_PADA_LANGKAH_SEBELUMNYA]@[GANTI_DENGAN_PROJECT_ID_ANDA].iam.gserviceaccount.com \
   --zone us-east1-b
##################################################################################################

##################################################################################################
#Task 5: Deploy an application to a private Kubernetes Engine cluster
#Akses SSH VM Instance orca-jumphost
#Jalankan script di bawah ini :
gcloud container clusters get-credentials [GANTI_DENGAN_NAMA_CLUSTER_YANG_DIBUAT_PADA_LANGKAH SEBLUMNYA] \
--internal-ip \
--zone us-east1-b \ 
--project [GANTI_DENGAN_PROJECT_ID_ANDA]
#Selanjutnya jalankan perintah berikut :
kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0
#################################################################################################



################################################################################################
#Selamat mencoba, apabila dalam prosesnya terjadi kesalahan, mohon kiranya review dan perbaikannya
#Terima kasih :)
#Salam, Laurensius Dede Suhardiman
################################################################################################