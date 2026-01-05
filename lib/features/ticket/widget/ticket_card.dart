import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/features/ticket/model/ticket_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.index,
    required this.ticketModel,
  });
  final int index;
  final TicketsModel ticketModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteHelper.ticketDetailsScreen,
            arguments: ticketModel.data![index].id!);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.cardRadius),
            border: Border(
              left: BorderSide(
                width: 5.0,
                color: ColorResources.ticketStatusColor(
                    ticketModel.data![index].status!),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${ticketModel.data![index].subject}',
                         style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ColorResources.ticketStatusColor(
                                ticketModel.data![index].status!)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ticketModel.data![index].statusName?.tr ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                           color: ColorResources.ticketStatusColor(
                              ticketModel.data![index].status!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                 Text(
                  Converter.parseHtmlString(
                      ticketModel.data![index].message ?? ''),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Expanded(
                       child: Row(
                        children: [
                           Icon(Icons.business,
                              size: 16, color: Theme.of(context).hintColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              ticketModel.data![index].company ?? '',
                               style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).hintColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                                           ),
                     ),
                     const SizedBox(width: 8),
                     Row(
                      children: [
                         Icon(Icons.calendar_today,
                            size: 14, color: Theme.of(context).hintColor),
                        const SizedBox(width: 6),
                        Text(
                          DateConverter.formatValidityDate(
                              ticketModel.data![index].dateCreated ?? ''),
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
