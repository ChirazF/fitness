import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  int pageIndex = 0; // 🔹 Garde l'index de la page actuelle
  final pageController = PageController(initialPage: 0); // 🔹 Contrôleur du PageView

  OnboardingBloc() : super(OnboardingInitial()) {
    // 🔹 Gestion de l'événement de swipe de page
    on<PageSwipedEvent>((event, emit) {
      pageIndex = event.index;
      emit(PageChangedState(counter: pageIndex));
      print("🔹 PageSwipedEvent: Nouvelle page index = $pageIndex");
    });

    // 🔹 Gestion du bouton "suivant"
    on<PageChangedEvent>((event, emit) {
      print("🛠 PageChangedEvent reçu, pageIndex actuel = $pageIndex");

      if (pageIndex == 2) {
        print("✅ Dernière page atteinte, passage à NextScreenState !");
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
