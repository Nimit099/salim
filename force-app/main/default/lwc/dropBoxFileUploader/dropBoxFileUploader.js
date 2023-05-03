import { LightningElement, wire, track, api } from 'lwc';
import getFolder from '@salesforce/apex/DropBoxController.getFolderFromDropbox';
import openSub from '@salesforce/apex/DropBoxController.getFolderFromDropbox_11';
import downloadFile from '@salesforce/apex/DropBoxController.downloadFileFromDropBox_V1';
import uploadFile from '@salesforce/apex/DropBoxController.uploadFile';
import createsubfolder from '@salesforce/apex/DropBoxController.createNewSubFolder';
import Getpathdata from '@salesforce/apex/DropBoxController.Getpathdata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DropboxLogo from '@salesforce/resourceUrl/DropboxLogo';
import folderimg from '@salesforce/resourceUrl/folderimg';
import fileimg from '@salesforce/resourceUrl/fileimg';
export default class DropBoxFileUploader extends LightningElement {

    @api recordId ;
    @track folderData = [];
    @track folderParent;
    @track folderName;
    @track mainFolder;
    @track folderURL;
    isLoaded = false;
    isShow = false;
    inputval;
    DownloadURL;
    vfpageerror = false;
    durl = DropboxLogo;
    fimg = folderimg;
    flimg = fileimg;
    pathrecord
    @track newfolder = [];

    @track isModal = false;
    connectedCallback() {
        if(this.recordId != undefined && this.recordId != '') {
            this.getpath();
            this.folderfetch();
        }
    }


    getpath(){

        console.log('OUTPUT : ', this.recordId);
        Getpathdata({ Id: this.recordId}).then(data => {
            console.log(data);
            this.folderURL = data; 
            console.log('getpath --> '+this.folderURL);
        }).catch(error => {
            this.isLoaded = false;
        });
    }


    folderfetch(){
        console.log('recordID --> '+this.recordId);
        this.isLoaded = true;
        getFolder({ recordId: this.recordId,accesstoken:'' })
        .then(data => {
            console.log({data});
            console.log(data.vferror);
                // if(data.vferror){
                //     console.log('error');
                //     this.vfpageerror = true;
                // }else{
                    console.log('data>>',data.folderFiles);
                    this.vfpageerror = false;
                    this.folderData = data.folderFiles;
                    this.folderParent = data.folderId;
                    this.folderName = data.folderName;
                    var pathurl = this.folderURL.replace(/ +/g, ' ');
                    console.log('pathurl -->'+pathurl);
                    if(!(pathurl.includes(this.folderName))){
                        if (this.folderName != undefined) {
                            this.folderURL += this.folderName+'/';
                            console.log('folder fetch after if '+this.folderURL);
                        }else{
                        }
                    }
                    this.mainFolder= data.folderName;
                // }
                this.isLoaded = false;

                var s1 = [];
                var s2 = [];
                this.folderData.forEach((element, index) => {
                    if(element.type == 'folder'){
                        s1.push({
                            label: element.id,
                            name: element.name,
                            itemtype: element.itemtype,
                            items: [],
                        });
                    }
                    else{
                        s1.push({
                            label: element.id,
                            name: element.name,
                            itemtype: element.itemtype,
                            items: [],
                        });
                    }
                });
                this.newfolder = s1;
                var items = [];
                items = this.newfolder;
                if (this.newfolder.length != 0) {
                    this.isShow = true;
                }

            }).catch(error => {
                this.isLoaded = false;
            });
    }

    createNewFolder() {
        this.isModal = true;
    }

    btnClickHandler(){
        var x = this.template.querySelector('input');
        x.click();
    }
    previousFolder(event){
        this.isLoaded = true;
        var oldURL = this.folderURL;
        console.log('oldUrl --> '+oldURL);
        const Arr = oldURL.split("/");
        var newURL = "/";
        Arr.pop();
        newURL = Arr.join("/");
        this.folderURL = newURL;
        this.isLoaded = true;
        console.log('newURL --> '+newURL);
        console.log('length --> '+Arr.length);
        if (Arr.length == 5){
            console.log('==5');
            this.folderfetch();
        }
        else if(Arr.length < 5){
            console.log('less than 5');
            this.folderURL = oldURL;
            this.folderfetch();
        }
        else if(Arr.length > 5) {
            console.log('more than 5');
            this.currentFolderRefresh();
        }
    }

    handleCheckbox(event){
        this.isLoaded = true;
        if(event.currentTarget.dataset.name == 'true'){
            this.isLoaded = true;
            var fileId = this.folderURL+'/'+event.currentTarget.dataset.fol;
            downloadFile({fileId: fileId}).then(data => {
                var link = document.createElement('a');
                link.innerHTML = 'Download PDF file';
                link.download = 'File';
                link.href = data;
                link.click();
                this.isLoaded = false;
                const event = new ShowToastEvent({
                    title: 'Toast message',
                    message: 'File Successfully Downloading!!!',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            }).catch(error=>{
                const event = new ShowToastEvent({
                    title: 'Toast message',
                    message: 'Sumthing went Wrong!!!',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            })

        }else{
            var name = event.currentTarget.dataset.fol;
            this.folderURL = this.folderURL+'/'+name;
            openSub({recordId:this.folderURL,folderName:event.currentTarget.dataset.fol,parentFol:this.folderName, accesstoken:''}).then(data=>{
                this.previousName = this.folderName;
                this.folderName = data.folderName;
                if(!this.folderURL.includes(data.folderName)){
                    if (this.folderName != undefined) {
                        this.folderURL += this.folderName+'/';
                    }else{
                    }
                }else{
                }  
                this.mainFolder= data.folderName;
                this.folderParent = data.folderId;
                this.folderData = data.folderFiles;
                this.isLoaded = false;
    
                var s1 = [];
                    var s2 = [];
                    this.folderData.forEach((element, index) => {
                        if(element.type == 'folder'){
                            s1.push({
                                label: element.id,
                                name: element.name,
                                itemtype: element.itemtype,
                                items: [],
                            });
                        }
                        else{
                            s1.push({
                                label: element.id,
                                name: element.name,
                                itemtype: element.itemtype,
                                items: [],
                            });
                        }
                    });
                    this.newfolder = s1;
                    if (this.newfolder.length != 0) {
                        this.isShow = true;
                    }
            }).catch(error=>{
                console.log({error});
            });
        }
    }

    handleFileUploaded(event) {
        // var that = this;
        console.log('upload function : ');
        this.isLoaded = true;
        var files = event.target.files;
        if (files.length > 0) {
            var file = files[0];
            this.getpath();
            var path = this.folderURL+'/'+file.name;
            var reader = new FileReader();
            console.log('OUTPUT : ',path);
            reader.onload = function () {
                var res = reader.result;
                var ress = res.split('base64,');
                console.log('OUTPUT2 before upload callout: ',ress[1]);
                uploadFile({ folderPath: path, baseVal: ress[1] }).then(data => {
                    //SUCCESSFULLY FILE UPLOADED
                //     const event = new ShowToastEvent({
                //     title: 'Toast message',
                //     message: 'File Successfully Uploaded!!!',
                //     variant: 'success',
                //     mode: 'dismissable'
                // });
                // this.dispatchEvent(event);
                    this.isLoaded = false;
                    // this.folderfetch();
                    

                }).catch(error => {
                    console.log('ERROR : ',error);
                    this.isLoaded = false;
                    const event1 = new ShowToastEvent({
                        title: 'Toast message',
                        message: 'File Successfully Upoaded!!',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event1);
                });
            };
            // this.currentFolderRefresh();
            reader.readAsDataURL(file);
        }
    }

    currentFolderRefresh(){
        var Arr = this.folderURL.split('/');
        var fname = Arr[Arr.length -1];
        console.log('Fname openSub --> '+fname);
        openSub({ recordId:'', folderName: fname, parentFol: ''}).then(data => {
                        this.previousName = this.folderName;
                        this.folderName = data.folderName;
                        this.folderParent = data.folderId;
                        this.folderData = data.folderFiles;
                        this.isLoaded = false;

                        var s1 = [];
                        var s2 = [];
                        this.folderData.forEach((element, index) => {
                            if (element.type == 'folder') {
                                s1.push({
                                    label: element.id,
                                    name: element.name,
                                    itemtype: element.itemtype,
                                    items: [],
                                });
                            }
                            else {
                                s1.push({
                                    label: element.id,
                                    name: element.name,
                                    itemtype: element.itemtype,
                                    items: [],
                                });
                            }
                        });
                        this.newfolder = s1;
                        if (this.newfolder.length != 0) {
                            this.isShow = true;
                        }
                    }).catch(error => {
                        this.isLoaded = false;
                    });
    }

    gotodropbox(){
        var currentLocation = window.location.href;
        var domain = currentLocation.replace('http://','').replace('https://','').split(/[/?#]/)[0];
        var vfpage = 'http://'+domain+'/apex/dropboxpage';
        openWin();
        var winopen;
        function openWin() {
            winopen = window
                     .open(vfpage, "_blank", "width=786, height=786");
        }
    }

    btnClickToRefresh(){
        this.isLoaded = true;
        var oldURL = this.folderURL;
        const Arr = oldURL.split("/");
        if (Arr.length == 5){
            this.folderfetch();
        }
        else if(Arr.length > 5) {
            this.currentFolderRefresh();
        }

    }

    handlechange(event) {
        this.inputval = event.target.value;
    }

    download(event){

        // Get file type
        var filetype = event.currentTarget.dataset.name;

        if(filetype == 'file'){
            this.isLoaded = true;
            var fileId = event.currentTarget.dataset.path;
            downloadFile({fileId: fileId}).then(data => {
                var link = document.createElement('a');
                link.innerHTML = 'Download PDF file';
                link.download = 'file.pdf';
                link.href = data;
                document.body.appendChild(link);
                link.click();
                this.isLoaded = false;
                const event = new ShowToastEvent({
                    title: 'Toast message',
                    message: 'File Successfully Downloading!!!',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            }).catch(error=>{
                this.isLoaded = false;
                const event = new ShowToastEvent({
                    title: 'Toast message',
                    message: 'Sumthing went Wrong!!!',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            })
        }else{
        }
    }

    create() {
        this.isLoaded = true;
        try {
            if(this.inputval != undefined || this.inputval != null){
                this.isModal = false;
                var ffn = this.folderURL+'/'+this.inputval;
                createsubfolder({ folderName: ffn })
                    .then(data => {
                        this.folderData.push(data);
                        const event = new ShowToastEvent({
                            title: 'Toast message',
                            message: 'Successfully folder created!!!',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.isLoaded = true;
                        var oldURL = this.folderURL;
                        const Arr = oldURL.split("/");
                        if (Arr.length == 5){
                            this.folderfetch();
                        }
                        else if(Arr.length > 5) {
                            this.currentFolderRefresh();
                        }
                        this.dispatchEvent(event);
                        this.isLoaded = false;
                    }).catch(error => {
                        this.isLoaded = false;
                        const event = new ShowToastEvent({
                            title: 'Toast message',
                            message: 'Sumthing went Wrong!!!',
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                    });   
            }
            else{
                this.template.querySelectorAll('lightning-input').forEach(element => {
                    element.reportValidity();
                });
            }
            this.inputval = null;
            this.currentFolderRefresh();
        } catch (error) {
            this.isLoaded = false;
        }
    }

    cancel(){
        this.isModal = false;
        this.vfpageerror = false;
        this.inputval = null;
    }

}