import { useBackend } from '../backend';
import { Knob, ProgressBar, Box, Section } from '../components';
import { Window } from '../layouts';
import { createLogger } from '../logging';
export const EngineControlConsole = (_props, context) => {
  const { act, data } = useBackend(context);
  const logger = createLogger('Debug');
  logger.warn(data);
  return (
    <Window width={455} height={275}>
      <Window.Content scrollable>
        <Section title="Engine Temperature">
          <Box textAlign="center">
            <ProgressBar
              width="180%"
              minValue={0}
              maxValue={180}
              value={data.temp}
              ranges={{
                good: [-Infinity, 50],
                bad: [100, Infinity],
              }}>
              <Box textAlign="center">{data.temp}% to overheat</Box>
            </ProgressBar>
          </Box>
        </Section>
        <Section title="Engine Efficiency">
          <Box textAlign="center">
            <ProgressBar
              width="180%"
              minValue={0}
              maxValue={180}
              value={data.temp}
              ranges={{
                good: [Infinity, 1],
                bad: [0.9, -Infinity],
              }}>
              <Box textAlign="center">
                {data.EngineEfficiency}% Engine Efficiency
              </Box>
            </ProgressBar>
          </Box>
        </Section>
        <Section title="Engine Control">
          {
            <LabeledList.Item label="Primary Engine Frequency">
              <Knob
                inline
                animated={false}
                maxValue={2}
                minValue={0}
                value={data.freq1g}
                onChange={(e, value) => act('p_freq', { value: value })}
                stepPixelSize={0.1}
              />
            </LabeledList.Item>
          }
          {
            <LabeledList.Item label="Secondary Engine Frequency">
              <Knob
                inline
                animated={false}
                maxValue={2}
                minValue={0}
                value={data.freq1g}
                onChange={(e, value) => act('s_freq', { value: value })}
                stepPixelSize={0.1}
              />
            </LabeledList.Item>
          }
          {
            <Button
              fontSize="20px"
              textAlign="center"
              fluid
              disabled={data.alt === 0.5}
              content="Calculate Frequency Deviation"
              iconPosition="right"
              onClick={() => act('calculate')}
            />
          }
        </Section>
      </Window.Content>
    </Window>
  );
};
