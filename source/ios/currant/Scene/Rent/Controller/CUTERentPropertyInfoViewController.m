//
//  CUTEPropertyInfoViewController.m
//  currant
//
//  Created by Foster Yin on 4/8/15.
//  Copyright (c) 2015 Foster Yin. All rights reserved.
//

#import "CUTERentPropertyInfoViewController.h"
#import "CUTERentContactViewController.h"
#import "CUTERentContactForm.h"
#import "CUTEDataManager.h"
#import <Bolts/Bolts.h>
#import "CUTEProperty.h"
#import <UIKit/UIKit.h>
#import <BBTRestClient.h>
#import "CUTEConfiguration.h"
#import <BBTJSON.h>
#import <NSArray+ObjectiveSugar.h>
#import <UIAlertView+Blocks.h>
#import "CUTEEnumManager.h"
#import "CUTECommonMacro.h"
#import "CUTERentPriceViewController.h"
#import "CUTERentPriceForm.h"
#import "CUTEAreaForm.h"
#import "CUTEPropertyInfoForm.h"
#import "SVProgressHUD+CUTEAPI.h"
#import "CUTEFormImagePickerCell.h"
#import "CUTERentPropertyMoreInfoViewController.h"
#import "CUTERentAreaViewController.h"
#import "CUTEUnfinishedRentTicketListViewController.h"
#import "CUTERentTypeListViewController.h"
#import "CUTERentTypeListForm.h"
#import "CUTERentAddressMapViewController.h"
#import "CUTENotificationKey.h"
#import "CUTERentTickePublisher.h"
#import "CUTERentAddressEditViewController.h"
#import "CUTERentAddressEditForm.h"
#import "CUTENavigationUtil.h"
#import "CUTERentTicketPreviewViewController.h"
#import "CUTETracker.h"
#import "Sequencer.h"
#import <NSDate-Extensions/NSDate-Utilities.h>
#import "CUTETicketEditingListener.h"

@interface CUTERentPropertyInfoViewController () {

    CUTERentAreaViewController *_editAreaViewController;

    CUTERentPriceViewController *_editRentPriceViewController;
}

@end


@implementation CUTERentPropertyInfoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = STR(@"房产信息");

    self.navigationItem.leftBarButtonItem = [CUTENavigationUtil backBarButtonItemWithTarget:self action:@selector(onLeftButtonPressed:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:STR(@"预览") style:UIBarButtonItemStylePlain target:self action:@selector(onPreviewButtonPressed:)];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    FXFormField *field = [self.formController fieldForIndexPath:indexPath];
    if ([field.key isEqualToString:@"photos"]) {
        CUTEFormImagePickerCell *pickerCell = (CUTEFormImagePickerCell *)cell;
        pickerCell.ticket = self.ticket;
        [pickerCell update];
    }
    else if ([field.key isEqualToString:@"rentPrice"]) {
        if (self.ticket.price) {
            cell.detailTextLabel.text = CONCAT([CUTECurrency symbolOfCurrencyUnit:self.ticket.price.unit], [NSString stringWithFormat:@"%.2lf", self.ticket.price.value], @"/", STR(@"周"));
        }
    }
    else if ([field.key isEqualToString:@"area"]) {
        if (self.ticket.space) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f %@", self.ticket.space.value, self.ticket.space.unitSymbol];
        }
    }
    else if ([field.key isEqualToString:@"rentType"]) {
        if (self.ticket.rentType) {
            cell.detailTextLabel.text = self.ticket.rentType.value;
        }
    }
    else if ([field.key isEqualToString:@"address"]) {
        if (self.ticket.property) {
            cell.detailTextLabel.text = self.ticket.property.address;
        }
    }
}

- (void)onLeftButtonPressed:(id)sender {

    if ([self.ticket.status isEqual:kTicketStatusDraft]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:STR(@"您确定放弃发布吗？放弃后系统将会将您已填写的信息保存为草稿") message:nil delegate:nil cancelButtonTitle:STR(@"放弃") otherButtonTitles:STR(@"取消"), nil];
        alertView.cancelButtonIndex = 1;
        alertView.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex)  {
            if (buttonIndex != alertView.cancelButtonIndex) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIF_TICKET_LIST_RELOAD object:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            }
        };
        [alertView show];

    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onPreviewButtonPressed:(id)sender {
    [self submit];
}

- (void)editLandlordType {
    CUTEPropertyInfoForm *form = (CUTEPropertyInfoForm *)self.formController.form;
    CUTETicketEditingListener *ticketListener = [CUTETicketEditingListener createListenerAndStartListenMarkWithSayer:self.ticket];
    self.ticket.landlordType = form.landlordType;
    [ticketListener stopListenMark];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIF_TICKET_SYNC object:nil userInfo:ticketListener.getSyncUserInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editPropertyType {
    CUTEPropertyInfoForm *form = (CUTEPropertyInfoForm *)self.formController.form;
    CUTETicketEditingListener *ticketListener = [CUTETicketEditingListener createListenerAndStartListenMarkWithSayer:self.ticket];
    self.ticket.property.propertyType = form.propertyType;
    [ticketListener stopListenMark];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIF_TICKET_SYNC object:nil userInfo:ticketListener.getSyncUserInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editRooms:(id)sender {
    CUTEPropertyInfoForm *form = (CUTEPropertyInfoForm *)self.formController.form;
    CUTETicketEditingListener *ticketListener = [CUTETicketEditingListener createListenerAndStartListenMarkWithSayer:self.ticket];
    self.ticket.property.bedroomCount = form.bedroomCount;
    self.ticket.property.livingroomCount = form.livingroomCount;
    self.ticket.property.bathroomCount = form.bathroomCount;
    [ticketListener stopListenMark];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIF_TICKET_SYNC object:nil userInfo:ticketListener.getSyncUserInfo];
}

- (void)editArea {
  if (!_editAreaViewController) {
      CUTERentAreaViewController *controller = [CUTERentAreaViewController new];
      controller.ticket = self.ticket;
      CUTEAreaForm *form = [CUTEAreaForm new];
      form.area = self.ticket.space.value;
      controller.formController.form = form;
      _editAreaViewController = controller;

      __weak typeof(self)weakSelf = self;
      _editAreaViewController.updateRentAreaCompletion = ^ {
          [weakSelf.formController enumerateFieldsWithBlock:^(FXFormField *field, NSIndexPath *indexPath) {
              if ([field.key isEqualToString:@"area"]) {
                  [[weakSelf tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
              }
          }];
      };

  }
  [self.navigationController pushViewController:_editAreaViewController animated:YES];
}

- (void)editRentPrice {
    NSArray *requiredEnums = @[@"deposit_type", @"rent_period"];
    [[BFTask taskForCompletionOfAllTasksWithResults:[requiredEnums map:^id(id object) {
        return [[CUTEEnumManager sharedInstance] getEnumsByType:object];
    }]] continueWithSuccessBlock:^id(BFTask *task) {
        if (!IsArrayNilOrEmpty(task.result) && [task.result count] == [requiredEnums count]) {
          if (!_editRentPriceViewController) {
              NSArray *depositTypes = task.result[0];
              NSArray *rentTypes = task.result[1];
              CUTETicket *ticket = self.ticket;
              if (!ticket.rentAvailableTime) {
                  ticket.rentAvailableTime = [[NSDate date] timeIntervalSince1970];
              }

//              if (!ticket.rentDeadlineTime) {
//                  ticket.rentDeadlineTime = [[[NSDate dateWithTimeIntervalSince1970:[ticket rentAvailableTime]] dateByAddingDays:1] timeIntervalSince1970];
//              }
              if (!ticket.minimumRentPeriod) {
                  ticket.minimumRentPeriod = [CUTETimePeriod timePeriodWithValue:1 unit:@"day"];
              }
              //TODO
//              if (!ticket.depositType) {
//                  ticket.depositType = [depositTypes find:^BOOL(id object) {
//                      return object != nil;
//                  }];
//              }

              CUTERentPriceViewController *controller = [[CUTERentPriceViewController alloc] init];
              controller.ticket = self.ticket;
              CUTERentPriceForm *form = [CUTERentPriceForm new];
              form.currency = ticket.price.unit;
              form.rentPrice = ticket.price.value;
              form.depositType = ticket.depositType;
              form.containBill = ticket.billCovered;
              form.needSetPeriod = YES;
              form.rentAvailableTime = [NSDate dateWithTimeIntervalSince1970:ticket.rentAvailableTime];
              form.rentDeadlineTime = [NSDate dateWithTimeIntervalSince1970:ticket.rentDeadlineTime];
              form.minimumRentPeriod = ticket.minimumRentPeriod;

              [form setAllDepositTypes:[task.result objectAtIndex:0]];
              controller.formController.form = form;
              controller.navigationItem.title = STR(@"租金");
              _editRentPriceViewController = controller;

              __weak typeof(self)weakSelf = self;
              _editRentPriceViewController.updatePriceCompletion = ^ {
                  [weakSelf.formController enumerateFieldsWithBlock:^(FXFormField *field, NSIndexPath *indexPath) {
                      if ([field.key isEqualToString:@"rentPrice"]) {
                          [[weakSelf tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                      }
                  }];
              };
          }
            [self.navigationController pushViewController:_editRentPriceViewController animated:YES];
        }

        return nil;
    }];

}

- (void)editRentType {
    [[[CUTEEnumManager sharedInstance] getEnumsByType:@"rent_type"] continueWithBlock:^id(BFTask *task) {
        if (task.result) {
            CUTERentTypeListForm *form = [[CUTERentTypeListForm alloc] init];
            form.singleUseForReedit = YES;
            form.rentType = self.ticket.rentType;
            [form setRentTypeList:task.result];
            CUTERentTypeListViewController *controller = [CUTERentTypeListViewController new];
            controller.ticket = self.ticket;
            controller.formController.form = form;

            __weak typeof(self)weakSelf = self;
            controller.updateRentTypeCompletion = ^ {
                [weakSelf.formController enumerateFieldsWithBlock:^(FXFormField *field, NSIndexPath *indexPath) {
                    if ([field.key isEqualToString:@"rentType"]) {
                        [[weakSelf tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }];
            };

            [self.navigationController pushViewController:controller animated:YES];

        }
        else {
            [SVProgressHUD showErrorWithError:task.error];
        }
        return nil;
    }];

}

- (void)editAddress {
    CUTERentAddressEditViewController *controller = [[CUTERentAddressEditViewController alloc] init];
    controller.ticket = self.ticket;
    CUTERentAddressEditForm *form = [CUTERentAddressEditForm new];
    form.singleUseForReedit = YES;
    [SVProgressHUD show];
    [[form updateWithTicket:self.ticket] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            [SVProgressHUD showErrorWithError:task.error];
        }
        else if (task.exception) {
            [SVProgressHUD showErrorWithException:task.exception];
        }
        else if (task.isCancelled) {
            [SVProgressHUD showErrorWithCancellation];
        }
        else {
            [SVProgressHUD dismiss];
            controller.lastCountry = form.country;
            controller.formController.form = form;
            controller.navigationItem.title = STR(@"地址");

            __weak typeof(self)weakSelf = self;
            controller.updateAddressCompletion = ^ {
                [weakSelf.formController enumerateFieldsWithBlock:^(FXFormField *field, NSIndexPath *indexPath) {
                    if ([field.key isEqualToString:@"location"]) {
                        [[weakSelf tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }];
            };
            [self.navigationController pushViewController:controller animated:YES];
        }

        return task;
    }];
}

- (void)editMoreInfo {

    TrackEvent(GetScreenName(self), kEventActionPress, @"enter-more", nil);
    CUTETicket *ticket = self.ticket;
    CUTERentPropertyMoreInfoViewController *controller = [CUTERentPropertyMoreInfoViewController new];
    controller.ticket = ticket;
    CUTEPropertyMoreInfoForm *form = [CUTEPropertyMoreInfoForm new];
    form.ticketTitle = ticket.titleForDisplay;
    form.ticketDescription = ticket.ticketDescription;
    controller.formController.form = form;

    [self.navigationController pushViewController:controller animated:YES];
}


- (BOOL)validate {
    CUTEPropertyInfoForm *form = (CUTEPropertyInfoForm *)self.formController.form;

    if (form.bedroomCount < 1) {
        [SVProgressHUD showErrorWithStatus:STR(@"居室数至少为1个")];
        return NO;
    }

    if (!_editRentPriceViewController && !self.ticket.price) {
        [SVProgressHUD showErrorWithStatus:STR(@"请编辑租金")];
        return NO;
    }
    if (fequalzero(self.ticket.price.value)) {
        [SVProgressHUD showErrorWithStatus:STR(@"租金不能为0")];
        return NO;
    }
    return YES;
}

- (void)submit
{
    if (![self validate]) {
        return;
    }

    [SVProgressHUD show];
    [[[CUTERentTickePublisher sharedInstance] editTicket:self.ticket updateStatus:^(NSString *status) {
        [SVProgressHUD showWithStatus:status];
    }] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            [SVProgressHUD showErrorWithError:task.error];
        }
        else if (task.exception) {
            [SVProgressHUD showErrorWithException:task.exception];
        }
        else if (task.isCancelled) {
            [SVProgressHUD showErrorWithCancellation];
        }
        else {
            [SVProgressHUD dismiss];
            [[CUTEDataManager sharedInstance] checkStatusAndSaveRentTicketToUnfinised:task.result];

            TrackScreenStayDuration(KEventCategoryPostRentTicket, GetScreenName(self));
            CUTERentTicketPreviewViewController *controller = [[CUTERentTicketPreviewViewController alloc] init];
            controller.ticket = self.ticket;
            [controller loadURL:[NSURL URLWithString:CONCAT(@"/wechat-poster/", self.ticket.identifier) relativeToURL:[CUTEConfiguration hostURL]]];
            [self.navigationController pushViewController:controller animated:YES];
        }
        return task;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

@end
