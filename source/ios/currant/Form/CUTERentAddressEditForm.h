//
//  CUTERentAddressEditForm.h
//  currant
//
//  Created by Foster Yin on 3/31/15.
//  Copyright (c) 2015 Foster Yin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CUTEForm.h"
#import "CUTEPropertyInfoForm.h"
#import "CUTEEnum.h"

@interface CUTERentAddressEditForm : CUTEForm

@property (strong, nonatomic) NSString *street;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *postCode;
@property (strong, nonatomic) NSString *country;

- (void)setDefaultCountry:(CUTEEnum *)country;

- (void)setAllCountries:(NSArray *)allCountries;

- (void)setDefaultCity:(CUTEEnum *)city;

- (void)setAllCities:(NSArray *)allCities;

@end
