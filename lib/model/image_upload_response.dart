
import 'package:chat_app/model/base_response.dart';

class ImageUploadResponse extends BaseResponse{

  String imageUrl;
  bool isLoading;

  ImageUploadResponse({this.imageUrl,this.isLoading,isSuccesful,message})
      :super(isSuccesful:isSuccesful,message:message);

}