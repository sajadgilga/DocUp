import 'package:bloc/bloc.dart';
import 'package:DocUp/constants/colors.dart';
import 'package:DocUp/models/DoctorEntity.dart';
import 'package:DocUp/models/PatientEntity.dart';
import 'package:DocUp/models/UserEntity.dart';
import 'package:DocUp/repository/DoctorRepository.dart';
import 'package:DocUp/repository/PatientRepository.dart';
import 'package:DocUp/ui/start/RoleType.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class EntityBloc extends Bloc<EntityEvent, EntityState> {
  PatientRepository _patientRepository = PatientRepository();
  DoctorRepository _doctorRepository = DoctorRepository();

  @override
  get initialState => EntityLoaded(entity: Entity(type: RoleType.DOCTOR));

  Stream<EntityState> _get() async* {
    Entity entity = state.entity;
    yield EntityLoading(entity: entity);
    try {
      UserEntity uEntity;
      if (state.entity.type == RoleType.PATIENT)
        uEntity = await _patientRepository.get();
      else if (state.entity.type == RoleType.DOCTOR)
        uEntity = await _doctorRepository.get();
      entity.mEntity = uEntity;
      _raiseGetPartnerEntity(entity);
      add(EntityChangeType(type: entity.type));
      yield EntityLoaded(entity: entity);
    } catch (e) {
      yield EntityError(entity: entity);
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
      _raiseUpdatePartnerEntity(entity);
      yield EntityLoaded(entity: entity);
    } catch (e) {
      print(e);
    }
  }

  void _raiseGetPartnerEntity(entity) {
    if (entity.type == RoleType.PATIENT) {
      var panels = (entity.mEntity as PatientEntity).panels;
      if (panels.length > 0) {
        for (var panel in panels) {
          if (panel.doctorId == null || panel.status < 2) continue;
          add(PartnerEntitySet(id: panel.doctorId, panelId: panel.id));
          break;
        }
      }
    } else if (state.entity.type == RoleType.DOCTOR) {
      var panels = (state.entity.mEntity as DoctorEntity).panels;
      if (panels.length > 0) {
        for (var panel in panels) {
          if (panel.patientId == null || panel.status < 2) continue;
          add(PartnerEntitySet(id: panel.patientId, panelId: panel.id));
          break;
        }
      }
    }
  }

  void _raiseUpdatePartnerEntity(Entity entity) {
    var partner = entity.partnerEntity.id;
    var panelId = entity.iPanelId;
    add(PartnerEntityUpdate(id: partner, panelId: panelId));
  }

  Stream<EntityState> _getPartner(id, panelId) async* {
    Entity entity = state.entity;
    yield EntityPartnerLoading(entity: entity);
    try {
      UserEntity uEntity;
      if (state.entity.type == RoleType.PATIENT)
        uEntity = await _doctorRepository.getDoctor(id);
      else if (state.entity.type == RoleType.DOCTOR)
        uEntity = await _patientRepository.getPatient(id);
      entity.partnerEntity = uEntity;
      entity.iPanelId = panelId;
      yield EntityLoaded(entity: entity);
    } catch (e) {
      yield EntityError(entity: entity);
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
      yield EntityLoaded(entity: entity);
    } catch (e) {
      yield EntityError(entity: entity);
    }
  }

  Stream<EntityState> _changeType(RoleType type) async* {
    Entity entity = state.entity;
    entity.type = type;
    IColors.changeThemeColor(type);
    yield EntityLoaded(entity: entity);
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
abstract class EntityState extends Equatable {
  final Entity entity;

  EntityState({@required this.entity});

  @override
  List<Object> get props => [];
}

class EntityLoading extends EntityState {
  final Entity entity;

  EntityLoading({@required this.entity});

  @override
  List<Object> get props => [entity];
}

class EntityPartnerLoading extends EntityState {
  final Entity entity;

  EntityPartnerLoading({@required this.entity});

  @override
  List<Object> get props => [entity];
}

class EntityLoaded extends EntityState {
  final Entity entity;

  EntityLoaded({@required this.entity});

  @override
  List<Object> get props => [entity];
}

class EntityError extends EntityState {
  final Entity entity;

  EntityError({@required this.entity});

  @override
  List<Object> get props => [entity];
}
