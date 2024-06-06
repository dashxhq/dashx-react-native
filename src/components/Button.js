import React from 'react';
import { TouchableOpacity, Text } from 'react-native';
import { styled } from 'nativewind';

const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledText = styled(Text);

const Button = ({ title, onPress, className }) => (
  <StyledTouchableOpacity onPress={onPress} className={`p-4 bg-blue-500 rounded ${className}`}>
    <StyledText className="text-white text-center">{title}</StyledText>
  </StyledTouchableOpacity>
);

export default Button;
