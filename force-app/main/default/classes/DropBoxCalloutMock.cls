@isTest
global class DropBoxCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        // System.assertEquals('https://api.dropboxapi.com/2/files/list_folder', req.getEndpoint());
        // System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint().endsWith('token')){
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"access_token":"sl.AbX9y6Fe3AuH5o66-gmJpR032jwAwQPIVVzWXZNkdzcYT02akC2de219dZi6gxYPVnYPrpvISRSf9lxKWJzYLjtMPH-d9fo_0gXex7X37VIvpty4-G8f4-WX45AcEPfRnJJDwzv-","expires_in":14400,"token_type":"bearer","scope":"account_info.readfiles.content.readfiles.content.writefiles.metadata.read","refresh_token":"nBiM85CZALsAAAAAAAAAAQXHBoNpNutK4ngsXHsqW4iGz9tisb3JyjGqikMJIYbd","account_id":"dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc","uid":"12345"}');
            res.setStatusCode(200);
        }
        else if (req.getEndpoint().endsWith('create_folder_v2')) {
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"metadata": {"name": "math", "path_lower": "/homework/math", "path_display": "/Homework/math", "id": "id:jJ260QfSPK4AAAAAAAABXg"}}');
            res.setStatusCode(200);
        }
        else if(req.getEndpoint().endsWith('list_folder')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"entries": [{".tag": "folder", "name": "PROJECTS IN PROGRESS", "path_lower": "/bluenest office/projects in progress", "path_display": "/BLUENEST OFFICE/PROJECTS IN PROGRESS", "id": "id:jJ260QfSPK4AAAAAAAABOg"}], "cursor": "AAHK2-lDJnhi4P0oAp5fNKI4AI7rexZCkr2_YhtP0HSgzidlhlRxcx6PtiFTm2u4bcGJ3GdrCAjJG6VWdCEbvVXCnC7DFY-vc2G55xtnbbfcGcx2u5KSBATwwAKXiXO-qAEnitYfa7qx_cj1L3BBsKKN1BnVnjGZeP9mmYD3aa5u18ySc9gUvqL3cx0TYX5N_N-BoazzZWM-VJWSU1oZsdL2uxf4HNK3MUA3GFsx4y1Vkw", "has_more": false}');
            res.setStatusCode(200);
        }
        else if(req.getEndpoint().endsWith('search_v2')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"has_more":false,"matches":[{"metadata":{".tag":"metadata","metadata":{".tag":"folder","client_modified":"2015-05-12T15:50:38Z","content_hash":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","has_explicit_shared_members":false,"id":"id:a4ayc_80_OEAAAAAAAAAXw","is_downloadable":true,"name":"Prime_Numbers.txt","path_display":"/Homework/math/Prime_Numbers.txt","path_lower":"/homework/math/prime_numbers.txt","rev":"a1c10ce0dd78","server_modified":"2015-05-12T15:50:38Z","sharing_info":{"modified_by":"dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc","parent_shared_folder_id":"84528192421","read_only":true},"size":7212}}}]}');
            res.setStatusCode(200);
        }
        else if(req.getEndpoint().endsWith('get_temporary_link')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"link":"https://ucabc123456.dl.dropboxusercontent.com/cd/0/get/abcdefghijklmonpqrstuvwxyz1234567890/file","metadata":{"client_modified":"2015-05-12T15:50:38Z","content_hash":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","file_lock_info":{"created":"2015-05-12T15:50:38Z","is_lockholder":true,"lockholder_name":"ImaginaryUser"},"has_explicit_shared_members":false,"id":"id:a4ayc_80_OEAAAAAAAAAXw","is_downloadable":true,"name":"Prime_Numbers.txt","path_display":"/Homework/math/Prime_Numbers.txt","path_lower":"/homework/math/prime_numbers.txt","property_groups":[{"fields":[{"name":"SecurityPolicy","value":"Confidential"}],"template_id":"ptid:1a5n2i6d3OYEAAAAAAAAAYa"}],"rev":"a1c10ce0dd78","server_modified":"2015-05-12T15:50:38Z","sharing_info":{"modified_by":"dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc","parent_shared_folder_id":"84528192421","read_only":true},"size":7212}}');
            res.setStatusCode(200);
        }
        else if(req.getEndpoint().endsWith('upload')){
            res.setHeader('Content-Type', 'application/octet-stream');
            res.setBody('{"link":"https://ucabc123456.dl.dropboxusercontent.com/cd/0/get/abcdefghijklmonpqrstuvwxyz1234567890/file","metadata":{"client_modified":"2015-05-12T15:50:38Z","content_hash":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","file_lock_info":{"created":"2015-05-12T15:50:38Z","is_lockholder":true,"lockholder_name":"ImaginaryUser"},"has_explicit_shared_members":false,"id":"id:a4ayc_80_OEAAAAAAAAAXw","is_downloadable":true,"name":"Prime_Numbers.txt","path_display":"/Homework/math/Prime_Numbers.txt","path_lower":"/homework/math/prime_numbers.txt","property_groups":[{"fields":[{"name":"SecurityPolicy","value":"Confidential"}],"template_id":"ptid:1a5n2i6d3OYEAAAAAAAAAYa"}],"rev":"a1c10ce0dd78","server_modified":"2015-05-12T15:50:38Z","sharing_info":{"modified_by":"dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc","parent_shared_folder_id":"84528192421","read_only":true},"size":7212}}');
            res.setStatusCode(200);
        }
        else if(req.getEndpoint().endsWith('move_v2')){
            res.setHeader('Content-Type', 'application/octet-stream');
            res.setBody('{"metadata":{".tag":"file","client_modified":"2015-05-12T15:50:38Z","content_hash":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","file_lock_info":{"created":"2015-05-12T15:50:38Z","is_lockholder":true,"lockholder_name":"ImaginaryUser"},"has_explicit_shared_members":false,"id":"id:a4ayc_80_OEAAAAAAAAAXw","is_downloadable":true,"name":"Prime_Numbers.txt","path_display":"/Homework/math/Prime_Numbers.txt","path_lower":"/homework/math/prime_numbers.txt","property_groups":[{"fields":[{"name":"SecurityPolicy","value":"Confidential"}],"template_id":"ptid:1a5n2i6d3OYEAAAAAAAAAYa"}],"rev":"a1c10ce0dd78","server_modified":"2015-05-12T15:50:38Z","sharing_info":{"modified_by":"dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc","parent_shared_folder_id":"84528192421","read_only":true},"size":7212}}');
            res.setStatusCode(200);
        }
        else{
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"access_token":"sl.AbX9y6Fe3AuH5o66-gmJpR032jwAwQPIVVzWXZNkdzcYT02akC2de219dZi6gxYPVnYPrpvISRSf9lxKWJzYLjtMPH-d9fo_0gXex7X37VIvpty4-G8f4-WX45AcEPfRnJJDwzv-","expires_in":14400,"token_type":"bearer","scope":"account_info.readfiles.content.readfiles.content.writefiles.metadata.read","refresh_token":"nBiM85CZALsAAAAAAAAAAQXHBoNpNutK4ngsXHsqW4iGz9tisb3JyjGqikMJIYbd","account_id":"dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc","uid":"12345"}');
            res.setStatusCode(200);
        }
       

        return res;
    }
}