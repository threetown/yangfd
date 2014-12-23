/* Created by frank on 14/10/21. */
window.getErrorMessage = function (domName, validator) {
    var inputMessageDic = {
        'nickname_required': i18n('姓名不能为空'),
        'phone_required': i18n('电话不能为空'),
        'phone_number': i18n('电话格式不正确'),
        'email_required': i18n('邮箱不能为空'),
        'email_email': i18n('邮箱格式不合法'),
        'code_required': i18n('验证码不能为空'),
        'password_required': i18n('密码不能为空'),
        'old_phone_required': i18n('原手机号不能为空'),
        'old_phone_number': i18n('原手机号格式不正确'),
        'old_password_required': i18n('当前密码不能为空'),
        'confirm_password_required': i18n('确认密码不能为空'),
        'confirm_password_sameAs': i18n('新密码和确认密码输入不一致')
    }
    return inputMessageDic[domName + '_' + validator] || ''
}


window.getErrorMessageFromErrorCode = function (errorCode, api) {
    var stringMap = {
        40000: i18n('参数错误'),
        40103: i18n('账户或密码错误'),
        40324: i18n('账户不存在'),
        40325: i18n('邮箱已被使用'),
        40351: i18n('电话已被使用, 请<a href="#" onclick="project.goToSignIn()">“登陆”</a>或者<a href="#" onclick="project.goToResetPassword()">“找回密码”</a>'),
        '40351/api/1/intention_ticket/add':i18n('电话已被使用, 请<a href="#" onclick="project.showSignInModal()">“登陆”</a>'),
        40357: i18n('验证失败'),
        40399: i18n('权限错误'),
        50314: i18n('第三方服务异常')
    }

    if (!api) {
        api = ''
    }
    return stringMap[errorCode + api] || errorCode
}

window.getBingMapEntityType = function (typeID) {
    //http://msdn.microsoft.com/en-us/library/hh478191.aspx
    var stringMap = {
        2084: i18n('Winery'),
        3578: i18n('ATM'),
        4013: i18n('Train Station'),
        4100: i18n('Commuter Rail Station'),
        4170: i18n('Bus Station'),
        4444: i18n('Named Place'),
        4482: i18n('Ferry Terminal'),
        4493: i18n('Marina'),
        4580: i18n('Public Sports Airport'),
        4581: i18n('Airport'),
        5000: i18n('Business Facility'),
        5400: i18n('Grocery Store'),
        5511: i18n('Auto Dealerships'),
        5512: i18n('Auto Dealership-Used Cars'),
        5540: i18n('Petrol/Gasoline Station'),
        5571: i18n('Motorcycle Dealership'),
        5800: i18n('Restaurant'),
        5813: i18n('Nightlife'),
        5999: i18n('Historical Monument'),
        6000: i18n('Bank'),
        6512: i18n('Shopping'),
        7011: i18n('Hotel'),
        7012: i18n('Ski Resort'),
        7013: i18n('Other Accommodation'),
        7014: i18n('Ski Lift'),
        7389: i18n('Tourist Information'),
        7510: i18n('Rental Car Agency'),
        7520: i18n('Parking Lot'),
        7521: i18n('Parking Garage/House'),
        7522: i18n('Park & Ride'),
        7538: i18n('Auto Service & Maintenance'),
        7832: i18n('Cinema'),
        7897: i18n('Rest Area'),
        7929: i18n('Performing Arts'),
        7933: i18n('Bowling Centre'),
        7940: i18n('Sports Complex'),
        7947: i18n('Park/Recreation Area'),
        7985: i18n('Casino'),
        7990: i18n('Convention/Exhibition Centre'),
        7992: i18n('Golf Course'),
        7994: i18n('Civic/Community Centre'),
        7996: i18n('Amusement Park'),
        7997: i18n('Sports Centre'),
        7998: i18n('Ice Skating Rink'),
        7999: i18n('Tourist Attraction'),
        8060: i18n('Hospital'),
        8200: i18n('Higher Education'),
        8211: i18n('School'),
        8231: i18n('Library'),
        8410: i18n('Museum'),
        8699: i18n('Automobile Club'),
        9121: i18n('City Hall'),
        9211: i18n('Court House'),
        9221: i18n('Police Station'),
        9500: i18n('Business Service'),
        9501: i18n('Other Communication'),
        9502: i18n('Telephone Service'),
        9503: i18n('Cleaning & Laundry'),
        9504: i18n('Hair & Beauty'),
        9505: i18n('Health Care Service'),
        9506: i18n('Mover'),
        9507: i18n('Photography'),
        9508: i18n('Video & Game Rental'),
        9509: i18n('Storage'),
        9510: i18n('Tailor & Alteration'),
        9511: i18n('Tax Service'),
        9512: i18n('Repair Service'),
        9513: i18n('Retirement/Nursing Home'),
        9514: i18n('Social Service'),
        9515: i18n('Utilities'),
        9516: i18n('Waste & Sanitary'),
        9517: i18n('Campground'),
        9518: i18n('Auto Parts'),
        9519: i18n('Car Wash/Detailing'),
        9520: i18n('Local Transit'),
        9521: i18n('Travel Agent & Ticketing'),
        9522: i18n('Truck Stop/Plaza'),
        9523: i18n('Church'),
        9524: i18n('Synagogue'),
        9525: i18n('Government Office'),
        9527: i18n('Fire Department'),
        9528: i18n('Road Assistance'),
        9529: i18n('Funeral Director'),
        9530: i18n('Post Office'),
        9531: i18n('Banquet Hall'),
        9532: i18n('Bar or Pub'),
        9533: i18n('Cocktail Lounge'),
        9534: i18n('Night Club'),
        9535: i18n('Convenience Store'),
        9536: i18n('Specialty Food Store'),
        9537: i18n('Clothing Store'),
        9538: i18n('Men\'s Apparel'),
        9539: i18n('Shoe Store'),
        9540: i18n('Specialty Clothing Store'),
        9541: i18n('Women\'s Apparel'),
        9542: i18n('Check Cashing Service'),
        9543: i18n('Currency Exchange'),
        9544: i18n('Money Transferring Service'),
        9545: i18n('Department Store'),
        9546: i18n('Discount Store'),
        9547: i18n('Other General Merchandise'),
        9548: i18n('Variety Store'),
        9549: i18n('Garden Center'),
        9550: i18n('Glass & Window'),
        9551: i18n('Hardware Store'),
        9552: i18n('Home Center'),
        9553: i18n('Lumber'),
        9554: i18n('Other House & Garden'),
        9555: i18n('Paint'),
        9556: i18n('Entertainment Electronics'),
        9557: i18n('Floor & Carpet'),
        9558: i18n('Furniture Store'),
        9559: i18n('Major Appliance'),
        9560: i18n('Home Specialty Store'),
        9561: i18n('Computer & Software'),
        9562: i18n('Flowers & Jewelry'),
        9563: i18n('Gift, Antique, & Art'),
        9564: i18n('Optical'),
        9565: i18n('Pharmacy'),
        9566: i18n('Record, CD, & Video'),
        9567: i18n('Specialty Store'),
        9568: i18n('Sporting Goods Store'),
        9569: i18n('Wine & Liquor'),
        9570: i18n('Boating'),
        9571: i18n('Theater'),
        9572: i18n('Race Track'),
        9573: i18n('Golf Practice Range'),
        9574: i18n('Health Club'),
        9575: i18n('Bowling Alley'),
        9576: i18n('Sports Activities'),
        9577: i18n('Recreation Center'),
        9578: i18n('Attorney'),
        9579: i18n('Dentist'),
        9580: i18n('Physician'),
        9581: i18n('Realtor'),
        9582: i18n('RV Park'),
        9583: i18n('Medical Service'),
        9584: i18n('Police Service'),
        9585: i18n('Veterinarian Service'),
        9586: i18n('Sporting & Instructional Camp'),
        9587: i18n('Agricultural Product Market'),
        9589: i18n('Public Restroom'),
        9590: i18n('Residential Area/Building'),
        9591: i18n('Cemetery'),
        9592: i18n('Highway Exit'),
        9593: i18n('Transportation Service'),
        9594: i18n('Lottery Booth'),
        9707: i18n('Public Transit Stop'),
        9708: i18n('Public Transit Access'),
        9709: i18n('Neighborhood'),
        9710: i18n('Weigh Station'),
        9714: i18n('Cargo Centre'),
        9715: i18n('Military Base'),
        9717: i18n('Tollbooth (China/Korea)'),
        9718: i18n('Animal Park'),
        9719: i18n('Truck Dealership'),
        9720: i18n('Truck Parking'),
        9986: i18n('Home Improvement & Hardware Store'),
        9987: i18n('Consumer Electronics Store'),
        9988: i18n('Office Supply & Services Store'),
        9989: i18n('Taxi Stand'),
        9990: i18n('Premium Default'),
        9991: i18n('Industrial Zone'),
        9992: i18n('Place of Worship'),
        9993: i18n('Embassy'),
        9994: i18n('County Council'),
        9995: i18n('Bookstore'),
        9996: i18n('Coffee Shop'),
        9998: i18n('Hamlet'),
        9999: i18n('Border Crossing'),
    }

    return stringMap[typeID]
}
