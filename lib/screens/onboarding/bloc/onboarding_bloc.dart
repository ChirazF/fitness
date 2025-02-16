import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  int pageIndex = 0;
  final pageController = PageController(initialPage: 0);

  OnboardingBloc() : super(OnboardingInitial()) {
    on<PageSwipedEvent>((event, emit) {
      pageIndex = event.index;
      emit(PageChangedState(counter: pageIndex));
      print("🔹 PageSwipedEvent: Nouvelle page index = $pageIndex");
    });

    on<PageChangedEvent>((event, emit) {
      print("🛠 PageChangedEvent reçu, pageIndex actuel = $pageIndex");

      if (pageIndex == 2) {
        print("✅ Dernière page atteinte, passage automatique à HomePage !");
        emit(NextScreenState());
        return;
      }

      pageIndex += 1;
      pageController.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );

      emit(PageChangedState(counter: pageIndex));
      print("✅ PageChangedState émis avec pageIndex = $pageIndex");
    });
  }
}
