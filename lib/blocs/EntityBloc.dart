import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/Panel.dart';
import 'package:Neuronio/models/PatientEntity.dart';
import 'package:Neuronio/models/Screening.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/repository/DoctorRepository.dart';
import 'package:Neuronio/repository/PatientRepository.dart';
import 'package:Neuronio/repository/ScreeningRepository.dart';
import 'package:Neuronio/ui/start/RoleType.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class EntityBloc extends Bloc<EntityEvent, EntityState> {
  PatientRepository _patientRepository = PatientRepository();
  DoctorRepository _doctorRepository = DoctorRepository();
  ScreeningRepository _screeningRepository = ScreeningRepository();

  @override
  get initialState => EntityState(
      entity: Entity(type: RoleType.DOCTOR),
      mEntityStatus: BlocState.Loading,
      partnerEntityStatus: BlocState.Loading);

  Stream<EntityState> _get() async* {
    Entity entity = state.entity;
    yield EntityState(
        entity: entity,
        mEntityStatus: BlocState.Loading,
        partnerEntityStatus: state.partnerEntityStatus);
    try {
      UserEntity uEntity;
      if (state.entity.type == RoleType.PATIENT)
        uEntity = await _patientRepository.get();
      else if (state.entity.type == RoleType.DOCTOR)
        uEntity = await _doctorRepository.get();
      entity.mEntity = uEntity;

      add(EntityChangeType(type: entity.type));
      yield EntityState(
          entity: entity,
          mEntityStatus: BlocState.Loaded,
          partnerEntityStatus: state.partnerEntityStatus);
      _raiseGetPartnerEntity(entity);
    } catch (e) {
      yield EntityState(
          entity: entity,
          mEntityStatus: BlocState.Error,
          partnerEntityStatus: state.partnerEntityStatus);
    }
  }

  Stream<EntityState> _update() async* {
    Entity entity = state.entity;
    try {
      UserEntity uEntity;
      if (state.entity.type == RoleType.PATIENT)
        uEntity = await _patientRepository.get();
      else if (state.entity.type == RoleType.DOCTOR)
        uEntity = await _doctorRepository.get();
      entity.mEntity = uEntity;
      yield EntityState(
          entity: entity,
          mEntityStatus: BlocState.Loaded,
          partnerEntityStatus: state.partnerEntityStatus);
      _raiseUpdatePartnerEntity(entity);
    } catch (e) {
      print(e);
    }
  }

  Future<Panel> _raiseGetPartnerEntity(Entity entity) async {
    if (state.entity.type == RoleType.PATIENT) {
      /// REMOVED CHANGING PARTNER ENTITY
      PatientScreeningResponse patientScreeningResponse =
          (await _screeningRepository.getPatientScreeningPlanIfExist());
      if (patientScreeningResponse.active == 1) {
        var panels = (entity.mEntity as PatientEntity).panels;
        if (panels.length > 0) {
          for (var panel in panels) {
            if (panel.doctorId ==
                patientScreeningResponse?.statusSteps?.doctor?.id) {
              add(PartnerEntitySet(id: panel.doctorId, panelId: panel.id));
              return panel;
            }
          }
        }
      }
    } else if (state.entity.type == RoleType.DOCTOR) {
      var panels = (state.entity.mEntity as DoctorEntity).panels;
      if (panels.length > 0) {
        for (var panel in panels) {
          if (panel.patientId == null) continue;
          add(PartnerEntitySet(id: panel.patientId, panelId: panel.id));
          return panel;
        }
      }
    }
    add(PartnerEntitySet(id: null, panelId: null));
    return null;
  }

  void _raiseUpdatePartnerEntity(Entity entity) async {
    if (entity.partnerEntity != null) {
      var partner = entity.partnerEntity?.id;
      var panelId = entity.iPanelId;
      add(PartnerEntityUpdate(id: partner, panelId: panelId));
    } else {
      Panel panel = await _raiseGetPartnerEntity(entity);
      if (panel != null) {
        if (state.entity.type == RoleType.PATIENT) {
          add(PartnerEntityUpdate(id: panel.doctorId, panelId: panel.id));
        } else if (state.entity.type == RoleType.DOCTOR) {
          add(PartnerEntityUpdate(id: panel.patientId, panelId: panel.id));
        }
      }
    }
  }

  Stream<EntityState> _getPartner(id, panelId) async* {
    Entity entity = state.entity;
    yield EntityState(
        entity: entity,
        mEntityStatus: state.mEntityStatus,
        partnerEntityStatus: BlocState.Loading);
    try {
      if(id != null){
        UserEntity uEntity;
        if (state.entity.type == RoleType.PATIENT)
          uEntity = await _doctorRepository.getDoctor(id);
        else if (state.entity.type == RoleType.DOCTOR)
          uEntity = await _patientRepository.getPatient(id);
        entity.partnerEntity = uEntity;
        entity.iPanelId = panelId;
      }

      yield EntityState(
          entity: entity,
          mEntityStatus: state.mEntityStatus,
          partnerEntityStatus: BlocState.Loaded);
    } catch (e) {
      print(e);
      yield EntityState(
          entity: entity,
          mEntityStatus: state.mEntityStatus,
          partnerEntityStatus: BlocState.Error);
    }
  }

  Stream<EntityState> _updatePartner(id, panelId) async* {
    Entity entity = state.entity;
    try {
      UserEntity uEntity;
      if (state.entity.type == RoleType.PATIENT)
        uEntity = await _doctorRepository.getDoctor(id);
      else if (state.entity.type == RoleType.DOCTOR)
        uEntity = await _patientRepository.getPatient(id);
      entity.partnerEntity = uEntity;
      entity.iPanelId = panelId;
      yield EntityState(
          entity: entity,
          mEntityStatus: state.mEntityStatus,
          partnerEntityStatus: BlocState.Loaded);
    } catch (e) {
      yield EntityState(
          entity: entity,
          mEntityStatus: state.mEntityStatus,
          partnerEntityStatus: BlocState.Error);
    }
  }

  Stream<EntityState> _changeType(RoleType type) async* {
    Entity entity = state.entity;
    entity.type = type;
    IColors.changeThemeColor(type);
    yield EntityState(
        entity: entity,
        mEntityStatus: state.partnerEntityStatus,
        partnerEntityStatus: state.partnerEntityStatus);
  }

  @override
  Stream<EntityState> mapEventToState(event) async* {
    if (event is EntityGet) {
      yield* _get();
    } else if (event is EntityUpdate)
      yield* _update();
    else if (event is PartnerEntityUpdate) {
      yield* _updatePartner(event.id, event.panelId);
    } else if (event is EntityChangeType) {
      yield* _changeType(event.type);
    } else if (event is PartnerEntitySet) {
      yield* _getPartner(event.id, event.panelId);
    }
  }
}

//events
abstract class EntityEvent {}

class EntityGet extends EntityEvent {}

class EntityChangeType extends EntityEvent {
  final RoleType type;

  EntityChangeType({@required this.type});
}

class EntityUpdate extends EntityEvent {}

/// partner events

class PartnerEntityUpdate extends EntityEvent {
  final int id;
  final int panelId;

  PartnerEntityUpdate({@required this.id, this.panelId});
}

class PartnerEntitySet extends EntityEvent {
  final int id;
  final int panelId;

  PartnerEntitySet({@required this.id, this.panelId});
}

//states
enum BlocState { Loading, Empty, Loaded, Error }

class EntityState {
  final BlocState mEntityStatus;
  final BlocState partnerEntityStatus;
  final Entity entity;

  EntityState(
      {@required this.entity,
      this.mEntityStatus = BlocState.Loading,
      this.partnerEntityStatus = BlocState.Loading});

  @override
  List<Object> get props => [];
}
