import { LightningElement, wire, track, api } from 'lwc';
import getFolder from '@salesforce/apex/DropBoxController.getFolderFromDropbox';
import downloadFile from '@salesforce/apex/DropBoxController.downloadFileFromDropBox_V1';
import uploadFile from '@salesforce/apex/DropBoxController.uploadFile';
import createsubfolder from '@salesforce/apex/DropBoxController.createNewSubFolder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DropboxLogo from '@salesforce/resourceUrl/DropboxLogo';
import folderimg from '@salesforce/resourceUrl/folderimg';
import fileimg from '@salesforce/resourceUrl/fileimg';
import Longitude from '@salesforce/schema/Lead.Longitude';
import MailingPostalCode from '@salesforce/schema/Contact.MailingPostalCode';
export default class DropBoxFileUploader extends LightningElement {

    @api recordId ;
    @track folderData = [];
    @track folderParent;
    @track folderName;
    isLoaded = false;
    inputval;
    vfpageerror = false;
    durl = DropboxLogo;
    fimg = folderimg;
    flimg = fileimg;
    @track newfolder = [];

    @track isModal = false;
    connectedCallback() {
        if(this.recordId != undefined && this.recordId != '') {
            this.folderfetch();
        }
    }

    folderfetch(){
        this.isLoaded = true;
        getFolder({ recordId: this.recordId }).then(data => {
                if(data.vferror == true){
                    this.vfpageerror = true;
                }else{
                    this.vfpageerror = false;
                    this.folderData = data.folderFiles;
                    this.folderParent = data.folderId;
                    this.folderName = data.folderName;
                }
                console.log(JSON.stringify(data.folderFiles));
                this.isLoaded = false;

                var s1 = [];
                var s2 = [];
                this.folderData.forEach((element, index) => {
                    console.log('index', index);
                    console.log(element.type);
                    if(element.type == 'folder'){
                        s1.push({
                            label: element.id,
                            name: element.name,
                            itemtype: element.itemtype,
                            items: [
                                {
                                    label: index+'element.id',
                                    name: index+'etes',
                                    itemtype: false,
                                    items: [
                                        {
                                            label: index+'/'+index+'element.id',
                                            name: index+'/etes',
                                            itemtype: false,
                                            items: [],
                                        }
                                    ],
                                },
                                {
                                    label: index+'52element.id',
                                    name: index+'etes',
                                    itemtype: false,
                                    items: [
                                        {
                                            label: index+'/'+index+'56element.id',
                                            name: index+'/etes',
                                            itemtype: false,
                                            items: [],
                                        }
                                    ],
                                }
                            ],
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
                console.log(s2);
                // s1.push({
                //     label: data.folderName,
                //     name: 1,
                //     expanded: true,
                //     items: s2,
                // });
                this.newfolder = s1;
                console.log(this.newfolder);

                // this.newfolder  = [
                //     {
                //         label: 'Western Sales Director',
                //         name: '1',
                //         expanded: true,
                //         items: [
                //             {
                //                 label: 'Western Sales Manager',
                //                 name: '2',
                //                 expanded: true,
                //                 items: [
                //                     {
                //                         label: 'CA Sales Rep',
                //                         name: '3',
                //                         expanded: true,
                //                         items: [],
                //                     },
                //                     {
                //                         label: 'OR Sales Rep',
                //                         name: '4',
                //                         expanded: true,
                //                         items: [],
                //                     },
                //                 ],
                //             },
                //         ],
                //     },
                //     {
                //         label: 'Eastern Sales Director',
                //         name: '5',
                //         expanded: false,
                //         items: [
                //             {
                //                 label: 'Easter Sales Manager',
                //                 name: '6',
                //                 expanded: true,
                //                 items: [
                //                     {
                //                         label: 'NY Sales Rep',
                //                         name: '7',
                //                         expanded: true,
                //                         items: [],
                //                     },
                //                     {
                //                         label: 'MA Sales Rep',
                //                         name: '8',
                //                         expanded: true,
                //                         items: [],
                //                     },
                //                 ],
                //             },
                //         ],
                //     },
                //     {
                //         label: 'International Sales Director',
                //         name: '9',
                //         expanded: true,
                //         items: [
                //             {
                //                 label: 'Asia Sales Manager',
                //                 name: '10',
                //                 expanded: true,
                //                 items: [
                //                     {
                //                         label: 'Sales Rep1',
                //                         name: '11',
                //                         expanded: true,
                //                         items: [],
                //                     },
                //                     {
                //                         label: 'Sales Rep2',
                //                         name: '12',
                //                         expanded: true,
                //                         items: [],
                //                     },
                //                 ],
                //             },
                //             {
                //                 label: 'Europe Sales Manager',
                //                 name: '13',
                //                 expanded: false,
                //                 items: [
                //                     {
                //                         label: 'Sales Rep1',
                //                         name: '14',
                //                         expanded: true,
                //                         items: [],
                //                     },
                //                     {
                //                         label: 'Sales Rep2',
                //                         name: '15',
                //                         expanded: true,
                //                         items: [],
                //                     },
                //                 ],
                //             },
                //         ],
                //     },
                // ];
                var items = [];
                items = this.newfolder;

                console.log(this.newfolder);
                console.log({items});
                console.log(JSON.stringify(this.newfolder));

            }).catch(error => {
                this.isLoaded = false;
                console.log({ error });
            });
    }

    createNewFolder() {
        this.isModal = true;
    }

    btnClickHandler(){
        var x = this.template.querySelector('input');
        x.click();
    }

    handleFileUploaded(event) {
        var that = this;
        this.isLoaded = true;
        var files = event.target.files;
        if (files.length > 0) {
            var file = files[0];
            var path = '/'+this.folderName+'/'+file.name;
            var reader = new FileReader();
            reader.onload = function () {
                var res = reader.result;
                var ress = res.split('base64,');
                uploadFile({ folderPath: path, baseVal: ress[1] }).then(data => {
                    //SUCCESSFULLY FILE UPLOADED
                    const event = new ShowToastEvent({
                        title: 'Toast message',
                        message: 'File Successfully Upoaded!!',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    dispatchEvent(event);
                    this.isLoaded = false;
                    that.folderfetch();
                }).catch(error => {
                    console.log({ error });
                    this.isLoaded = false;
                    const event = new ShowToastEvent({
                        title: 'Toast message',
                        message: 'File Successfully Upoaded!!',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    dispatchEvent(event);
                });
            };
            reader.readAsDataURL(file);
        }
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
        getFolder({ recordId: this.recordId }).then(data => {
                if(data.vferror == true){
                    this.vfpageerror = true;
                }else{
                    this.vfpageerror = false;
                    this.folderData = data.folderFiles;
                    this.folderParent = data.folderId;
                    this.folderName = data.folderName;
                    const event = new ShowToastEvent({
                        title: 'Toast message',
                        message: 'Successfully Page Refreshed!!!',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                }
                this.isLoaded = false;
            }).catch(error => {
                console.log({ error });
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
                console.log({error});
                const event = new ShowToastEvent({
                    title: 'Toast message',
                    message: 'Sumthing went Wrong!!!',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            })
        }else{
            console.log('folder selected');
        }
    }

    create() {
        this.isLoaded = true;
        try {
            if(this.inputval != undefined || this.inputval != null){
                this.isModal = false;
                var ffn = this.folderName+'/'+this.inputval;
                console.log('Input==>', this.inputval);
                createsubfolder({ folderName: ffn })
                    .then(data => {
                        this.folderData.push(data);
                        const event = new ShowToastEvent({
                            title: 'Toast message',
                            message: 'Successfully folder created!!!',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        this.isLoaded = false;
                    }).catch(error => {
                        console.log({ error });
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
        } catch (error) {
            console.log({error});
            this.isLoaded = false;
        }
    }

    cancel(){
        this.isModal = false;
        this.vfpageerror = false;
        this.inputval = null;
    }

}